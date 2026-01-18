#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Dependency Resolution Library
# ═══════════════════════════════════════════════════════════════════════════════
# Handles dependency resolution, topological sorting, and circular dependency detection
# Used by: Orbit Controller (vibe command)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Source core library if not already loaded
if [[ -z "${VIBE_DIR:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/core.sh"
fi

# Declare global associative arrays for topological sort
# These are used by deps_sort_topological and __deps_calculate_depth
declare -gA __deps_depth=()
declare -gA __deps_in_progress=()

# Directory where planet scripts are located
# Default to relative path if not set
if [[ -z "${PLANETS_DIR:-}" ]]; then
    if [[ -n "${SCRIPT_DIR:-}" ]]; then
        PLANETS_DIR="$SCRIPT_DIR/../planets"
    else
        # Fallback if script is being sourced
        PLANETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../planets"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET DISCOVERY
# ═══════════════════════════════════════════════════════════════════════════════

# deps_list_all: List all available planets
# Returns: Array of planet names (one per line)
# Usage: deps_list_all
deps_list_all() {
    local planets=()

    # Find all .sh files in planets directory
    while IFS= read -r -d '' file; do
        local planet_name
        planet_name=$(basename "$file" .sh)

        # Skip example planet and non-planet files
        if [[ "$planet_name" == "example" ]]; then
            continue
        fi

        planets+=("$planet_name")
    done < <(find "$PLANETS_DIR" -name "*.sh" -type f -print0 2>/dev/null | sort -z)

    # Print each planet on its own line
    printf '%s\n' "${planets[@]}"
}

# deps_planet_exists: Check if a planet exists
# Returns: 0 if exists, 1 if not
# Usage: if deps_planet_exists "mercury"; then ...; fi
deps_planet_exists() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    [[ -f "$planet_script" ]]
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY EXTRACTION
# ═══════════════════════════════════════════════════════════════════════════════

# deps_get: Get dependencies for a planet
# Returns: Array of planet names (space-separated, one per line)
# Usage: deps_get "venus"
deps_get() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    if ! deps_planet_exists "$planet"; then
        error "Planet not found: $planet"
        return 1
    fi

    # Source the planet script temporarily
    # We need to extract the planet_dependencies function
    if source "$planet_script" 2>/dev/null; then
        local deps
        deps=$(planet_dependencies 2>/dev/null || echo "")

        # If dependencies returned as space-separated, convert to one per line
        # Trim whitespace and check if non-empty
        deps=$(echo "$deps" | tr ' ' '\n' | grep -v '^$' | sort -u || true)

        if [[ -n "$deps" ]]; then
            echo "$deps"
        fi
    else
        error "Failed to source planet: $planet"
        return 1
    fi
}

# deps_get_all_recursive: Get all dependencies recursively
# Returns: Array of all planet names (one per line)
# Usage: deps_get_all_recursive "saturn"
deps_get_all_recursive() {
    local planet="$1"
    local visited=()
    local to_visit=("$planet")

    # Keep track of visited to prevent infinite loops
    # and to deduplicate

    while [[ ${#to_visit[@]} -gt 0 ]]; do
        local current="${to_visit[0]}"
        # Remove first element
        to_visit=("${to_visit[@]:1}")

        # Skip if already visited
        if [[ " ${visited[*]} " =~ " $current " ]]; then
            continue
        fi

        visited+=("$current")

        # Get dependencies of current planet
        if deps_planet_exists "$current"; then
            local deps
            deps=$(deps_get "$current" 2>/dev/null || echo "")

            # Add unvisited dependencies to to_visit
            while IFS= read -r dep; do
                if [[ -n "$dep" ]] && [[ ! " ${visited[*]} " =~ " $dep " ]]; then
                    to_visit+=("$dep")
                fi
            done <<< "$deps"
        fi
    done

    # Print all dependencies except the target planet itself
    for p in "${visited[@]}"; do
        if [[ "$p" != "$planet" ]]; then
            echo "$p"
        fi
    done | sort -u
}

# ═══════════════════════════════════════════════════════════════════════════════
# CIRCULAR DEPENDENCY DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

# deps_check_circular: Check for circular dependencies
# Returns: 0 if no circular deps, 1 if circular deps found
# Usage: if deps_check_circular "venus"; then ...; fi
deps_check_circular() {
    local planet="$1"
    local visiting=()
    local visited=()

    # Recursive function to detect cycles
    __detect_cycle() {
        local current="$1"

        # If we're currently visiting this node, we found a cycle
        if [[ " ${visiting[*]} " =~ " $current " ]]; then
            error "Circular dependency detected: ${visiting[*]} $current"
            return 1
        fi

        # If already visited, skip
        if [[ " ${visited[*]} " =~ " $current " ]]; then
            return 0
        fi

        # Mark as visiting
        visiting+=("$current")

        # Check dependencies
        if deps_planet_exists "$current"; then
            local deps
            deps=$(deps_get "$current" 2>/dev/null || echo "")

            while IFS= read -r dep; do
                if [[ -n "$dep" ]]; then
                    if ! __detect_cycle "$dep"; then
                        return 1
                    fi
                fi
            done <<< "$deps"
        fi

        # Mark as visited and remove from visiting
        visited+=("$current")
        # Remove from visiting (a bit hacky in bash, but works)
        local new_visiting=()
        for v in "${visiting[@]}"; do
            if [[ "$v" != "$current" ]]; then
                new_visiting+=("$v")
            fi
        done
        visiting=("${new_visiting[@]}")

        return 0
    }

    __detect_cycle "$planet"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TOPOLOGICAL SORT (INSTALLATION ORDER)
# ═══════════════════════════════════════════════════════════════════════════════

# Helper function for topological sort (defined outside to avoid scoping issues)
# Uses global variables __deps_depth and __deps_in_progress
__deps_calculate_depth() {
    local current="$1"

    # Ensure arrays are associative ( sourcing planet scripts might mess this up )
    if ! declare -p __deps_depth 2>/dev/null | grep -q associative; then
        declare -gA __deps_depth=()
    fi
    if ! declare -p __deps_in_progress 2>/dev/null | grep -q associative; then
        declare -gA __deps_in_progress=()
    fi

    # If already calculated, return (use eval for safety)
    local current_depth
    eval "current_depth=\"\${__deps_depth[$current]:-}\""
    if [[ -n "$current_depth" ]]; then
        return 0
    fi

    # If we're in progress, we have a cycle (shouldn't happen due to check above)
    local current_progress
    eval "current_progress=\"\${__deps_in_progress[$current]:-}\""
    if [[ -n "$current_progress" ]]; then
        error "Cycle detected during topological sort: $current"
        return 1
    fi

    # Mark as in progress (use eval for safety)
    eval "__deps_in_progress[\"\$current\"]=1"

    # Get dependencies
    local deps
    deps=$(deps_get "$current" 2>/dev/null || echo "")

    local max_dep_depth=0
    while IFS= read -r dep; do
        # Skip empty lines and ensure dep is a valid planet name
        if [[ -n "$dep" ]] && [[ "$dep" =~ ^[a-z]+$ ]]; then
            # Recursively calculate depth
            __deps_calculate_depth "$dep"

            # Re-check arrays after recursive call ( sourcing might have messed them up )
            if ! declare -p __deps_depth 2>/dev/null | grep -q associative; then
                declare -gA __deps_depth=()
            fi

            # Use indirect reference with -v test to safely access the array
            local dep_depth=0
            if [[ -v "__deps_depth[$dep]" ]]; then
                dep_depth="${__deps_depth[$dep]}"
            fi
            if [[ $dep_depth -gt $max_dep_depth ]]; then
                max_dep_depth=$dep_depth
            fi
        fi
    done <<< "$deps"

    # Re-check before assignment
    if ! declare -p __deps_depth 2>/dev/null | grep -q associative; then
        declare -gA __deps_depth=()
    fi

    # Depth is max dependency depth + 1 (use eval for safety)
    eval "__deps_depth[\"\$current\"]=$((max_dep_depth + 1))"

    # Mark as no longer in progress
    unset __deps_in_progress["$current"]

    return 0
}

# deps_sort_topological: Calculate installation order using topological sort
# Returns: List of planet names in installation order (one per line)
# Usage: deps_sort_topological "venus"
deps_sort_topological() {
    local planet="$1"

    # Check for circular dependencies first
    if ! deps_check_circular "$planet"; then
        return 1
    fi

    # Get all recursive dependencies
    local all_deps
    all_deps=$(deps_get_all_recursive "$planet")

    # Note: We use the global __deps_depth and __deps_in_progress arrays
    # They accumulate data across calls, but that's OK since we overwrite values

    # Calculate depth for target and all its dependencies
    __deps_calculate_depth "$planet"

    while IFS= read -r dep; do
        if [[ -n "$dep" ]] && [[ "$dep" =~ [a-zA-Z] ]]; then
            __deps_calculate_depth "$dep"
        fi
    done <<< "$all_deps"

    # Sort by depth (ascending), then by name for consistency
    {
        # Include all dependencies
        echo "$all_deps"
        # Include the target planet itself
        echo "$planet"
    } | while IFS= read -r p; do
        if [[ -n "$p" ]]; then
            # Use eval for safe array access
            local depth_val
            eval "depth_val=\"\${__deps_depth[$p]:-0}\""
            echo "$depth_val $p"
        fi
    done | sort -n -k1 | awk '{print $2}'
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY TREE VISUALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# deps_show_tree: Display dependency tree for a planet
# Usage: deps_show_tree "saturn"
deps_show_tree() {
    local planet="$1"

    if ! deps_planet_exists "$planet"; then
        error "Planet not found: $planet"
        return 1
    fi

    echo "$planet"

    __show_tree_helper() {
        local current="$1"
        local prefix="$2"
        local is_last="$3"

        local deps
        deps=$(deps_get "$current" 2>/dev/null || echo "")

        local dep_count=0
        while IFS= read -r dep; do
            [[ -n "$dep" ]] && ((dep_count++))
        done <<< "$deps"

        local current_index=0
        while IFS= read -r dep; do
            if [[ -z "$dep" ]]; then
                continue
            fi

            ((current_index++))
            local is_last_dep=$((current_index == dep_count))

            local connector="├──"
            local child_prefix="│   "

            if [[ $is_last_dep -eq 1 ]]; then
                connector="└──"
                child_prefix="    "
            fi

            echo "${prefix}${connector} $dep"
            __show_tree_helper "$dep" "${prefix}${child_prefix}" $is_last_dep
        done <<< "$deps"
    }

    __show_tree_helper "$planet" "" 1
}

# deps_show_graph: Display all planets and their dependencies
# Usage: deps_show_graph
deps_show_graph() {
    echo "Dependency Graph:"
    echo "=================="

    while IFS= read -r planet; do
        if [[ -z "$planet" ]]; then
            continue
        fi

        local deps
        deps=$(deps_get "$planet" 2>/dev/null || echo "")

        if [[ -z "$deps" ]]; then
            echo "$planet (no dependencies)"
        else
            echo "$planet -> $deps"
        fi
    done < <(deps_list_all)
}

# ═══════════════════════════════════════════════════════════════════════════════
# BATCH INSTALLATION ORDER
# ═══════════════════════════════════════════════════════════════════════════════

# deps_resolve_install_order: Calculate install order for multiple planets
# Returns: List of planet names in installation order
# Usage: deps_resolve_install_order "mercury" "venus" "mars"
deps_resolve_install_order() {
    local planets=("$@")

    if [[ ${#planets[@]} -eq 0 ]]; then
        return 0
    fi

    # Build a unified list of all planets and their dependencies
    declare -A all_planets
    declare -A visited

    for planet in "${planets[@]}"; do
        all_planets["$planet"]=1
    done

    # Add all dependencies
    for planet in "${planets[@]}"; do
        local deps
        deps=$(deps_get_all_recursive "$planet" 2>/dev/null || echo "")

        while IFS= read -r dep; do
            if [[ -n "$dep" ]]; then
                all_planets["$dep"]=1
            fi
        done <<< "$deps"
    done

    # Sort all planets topologically
    declare -A depth
    declare -A in_progress

    __calculate_depth_batch() {
        local current="$1"

        if [[ -n "${depth[$current]:-}" ]]; then
            return 0
        fi

        if [[ -n "${in_progress[$current]:-}" ]]; then
            error "Cycle detected: $current"
            return 1
        fi

        in_progress["$current"]=1

        local deps
        deps=$(deps_get "$current" 2>/dev/null || echo "")

        local max_dep_depth=0
        while IFS= read -r dep; do
            if [[ -n "$dep" ]]; then
                __calculate_depth_batch "$dep"
                local dep_depth="${depth[$dep]:-0}"
                if [[ $dep_depth -gt $max_dep_depth ]]; then
                    max_dep_depth=$dep_depth
                fi
            fi
        done <<< "$deps"

        depth["$current"]=$((max_dep_depth + 1))
        unset in_progress["$current"]

        return 0
    }

    # Calculate depth for all planets
    for planet in "${!all_planets[@]}"; do
        __calculate_depth_batch "$planet"
    done

    # Output sorted by depth
    for planet in "${!all_planets[@]}"; do
        echo "${depth[$planet]:-0} $planet"
    done | sort -n -k1 | awk '{print $2}'
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

export -f deps_list_all deps_planet_exists
export -f deps_get deps_get_all_recursive
export -f deps_check_circular
export -f deps_sort_topological
export -f deps_show_tree deps_show_graph
export -f deps_resolve_install_order
