#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet Validator
# ═══════════════════════════════════════════════════════════════════════════════
# Validates that a planet script conforms to the interface specification
# Usage: ./scripts/validate-planet.sh <planet-script>
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core library
source "$SCRIPT_DIR/../lib/core.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Required function names
REQUIRED_FUNCTIONS=(
    "planet_metadata"
    "planet_dependencies"
    "planet_install"
    "planet_uninstall"
    "planet_check_health"
    "planet_is_installed"
)

# validate_planet: Validate a planet script
validate_planet() {
    local planet_file="$1"

    log "Validating planet: $planet_file"

    # Check file exists
    if [[ ! -f "$planet_file" ]]; then
        error "Planet file not found: $planet_file"
        return 1
    fi

    # Check file is executable
    if [[ ! -x "$planet_file" ]]; then
        warn "Planet file is not executable, fixing..."
        chmod +x "$planet_file"
        success "Made executable"
    fi

    # Source the planet script to check functions
    # Use subshell to avoid polluting current environment
    local missing_functions=()
    local defined_functions=()

    # Extract function definitions from the file
    while IFS= read -r line; do
        if [[ "$line" =~ ^([a-z_][a-z0-9_]*)\(\)[[:space:]]*\{ ]]; then
            defined_functions+=("${BASH_REMATCH[1]}")
        fi
    done < "$planet_file"

    # Check each required function
    for func in "${REQUIRED_FUNCTIONS[@]}"; do
        local found=false
        for defined in "${defined_functions[@]}"; do
            if [[ "$defined" == "$func" ]]; then
                found=true
                break
            fi
        done

        if $found; then
            success "✓ $func defined"
        else
            error "✗ $func MISSING"
            missing_functions+=("$func")
        fi
    done

    # Validate metadata output
    step "Validating metadata"
    if source_and_call "$planet_file" "planet_metadata" >/dev/null 2>&1; then
        local metadata
        metadata=$(source_and_call "$planet_file" "planet_metadata")

        # Validate JSON
        if echo "$metadata" | jq empty 2>/dev/null; then
            success "✓ Metadata returns valid JSON"

            # Check required fields
            local name version description duration
            name=$(echo "$metadata" | jq -r '.name // empty')
            version=$(echo "$metadata" | jq -r '.version // empty')
            description=$(echo "$metadata" | jq -r '.description // empty')
            duration=$(echo "$metadata" | jq -r '.duration // empty')

            if [[ -n "$name" ]]; then
                success "  ✓ name: $name"
            else
                error "  ✗ name field missing"
                missing_functions+=("metadata.name")
            fi

            if [[ -n "$version" ]]; then
                success "  ✓ version: $version"
            else
                error "  ✗ version field missing"
                missing_functions+=("metadata.version")
            fi

            if [[ -n "$description" ]]; then
                success "  ✓ description: $description"
            else
                error "  ✗ description field missing"
                missing_functions+=("metadata.description")
            fi

            if [[ -n "$duration" ]]; then
                success "  ✓ duration: $duration"
            else
                error "  ✗ duration field missing"
                missing_functions+=("metadata.duration")
            fi
        else
            error "✗ Metadata does not return valid JSON"
            missing_functions+=("metadata.json")
        fi
    else
        error "✗ planet_metadata() failed to execute"
        missing_functions+=("metadata.executable")
    fi

    # Validate dependencies output
    step "Validating dependencies"
    if source_and_call "$planet_file" "planet_dependencies" >/dev/null 2>&1; then
        local deps
        deps=$(source_and_call "$planet_file" "planet_dependencies")
        success "✓ planet_dependencies() executes"
        log "  Dependencies: ${deps:-none}"
    else
        error "✗ planet_dependencies() failed to execute"
        missing_functions+=("dependencies.executable")
    fi

    # Check shebang
    step "Validating shebang"
    local shebang
    shebang=$(head -n 1 "$planet_file")
    if [[ "$shebang" =~ ^#!/ ]]; then
        success "✓ Valid shebang: $shebang"
    else
        error "✗ Missing or invalid shebang"
        missing_functions+=("shebang")
    fi

    # Check for set -euo pipefail
    step "Validating error handling"
    if grep -q "set -euo pipefail" "$planet_file"; then
        success "✓ Error handling enabled (set -euo pipefail)"
    else
        warn "⚠ Missing 'set -euo pipefail' for error handling"
    fi

    # Check sourcing of core libraries
    step "Validating library imports"
    if grep -q "source.*lib/core.sh" "$planet_file"; then
        success "✓ Sources lib/core.sh"
    else
        error "✗ Does not source lib/core.sh"
        missing_functions+=("lib.core")
    fi

    if grep -q "source.*lib/state.sh" "$planet_file"; then
        success "✓ Sources lib/state.sh"
    else
        error "✗ Does not source lib/state.sh"
        missing_functions+=("lib.state")
    fi

    # Final verdict
    echo ""
    banner "Validation Summary"

    if [[ ${#missing_functions[@]} -eq 0 ]]; then
        success "Planet validation PASSED ✓"
        echo ""
        log "Planet is ready for use in the Vibe Solar System"
        return 0
    else
        error "Planet validation FAILED ✗"
        echo ""
        error "Missing/Invalid items: ${missing_functions[*]}"
        echo ""
        log "Please fix the above issues before using this planet"
        return 1
    fi
}

# source_and_call: Source a planet script and call a function
# Returns the function output
source_and_call() {
    local planet_file="$1"
    local func_name="$2"

    # Source in subshell and call function
    (
        source "$planet_file"
        "$func_name"
    )
}

# show_help: Display usage information
show_help() {
    cat <<EOF
${BOLD}Vibe Palace - Planet Validator${NC}

${CYAN}Usage:${NC}
    $0 <planet-script>

${CYAN}Description:${NC}
    Validates that a planet script conforms to the Vibe Palace
    planet interface specification.

${CYAN}Required Functions:${NC}
    - planet_metadata()      Return planet info as JSON
    - planet_dependencies()  List dependency planets
    - planet_install()       Install the planet
    - planet_uninstall()     Uninstall the planet
    - planet_check_health()  Run health checks
    - planet_is_installed()  Check if installed

${CYAN}Example:${NC}
    $0 planets/mercury.sh

EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    local planet_file="$1"

    # Show help if no argument or --help
    if [[ -z "$planet_file" ]] || [[ "$planet_file" == "--help" ]] || [[ "$planet_file" == "-h" ]]; then
        show_help
        exit 0
    fi

    # Validate the planet
    if validate_planet "$planet_file"; then
        exit 0
    else
        exit 1
    fi
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
