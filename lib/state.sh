#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - State Management Library
# ═══════════════════════════════════════════════════════════════════════════════
# Manages installation state for all Vibe Palace planets
# Tracks: installed planets, versions, checksums, timestamps
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Source core library if not already loaded
if [[ -z "${VIBE_DIR:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/core.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STATE FILE CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

export STATE_FILE="${STATE_FILE:-$VIBE_DIR/state.json}"
export STATE_LOCK="${STATE_LOCK:-$VIBE_DIR/state.lock}"

# Default state structure (if file doesn't exist)
DEFAULT_STATE='{
  "version": "1.0",
  "installed": {},
  "last_update": null
}'

# ═══════════════════════════════════════════════════════════════════════════════
# STATE INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# state_init: Initialize state file and directory
# Creates state file if it doesn't exist
# Usage: state_init
state_init() {
    # Ensure VIBE_DIR exists
    ensure_dir "$VIBE_DIR"

    # Create state file if it doesn't exist
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "$DEFAULT_STATE" > "$STATE_FILE"
        log "Initialized state file: $STATE_FILE"
    fi

    return 0
}

# state_lock: Acquire lock for state modification
# Prevents concurrent modifications
# Usage: state_lock
state_lock() {
    local max_wait=30
    local waited=0

    while [[ -f "$STATE_LOCK" ]]; do
        if [[ $waited -ge $max_wait ]]; then
            error "State lock timeout. Remove $STATE_LOCK if stale."
            return 1
        fi
        sleep 1
        ((waited++))
    done

    # Create lock file with PID
    echo $$ > "$STATE_LOCK"
    return 0
}

# state_unlock: Release state lock
# Usage: state_unlock
state_unlock() {
    rm -f "$STATE_LOCK" 2>/dev/null || true
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATE READ OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# state_get: Get information about a planet
# Returns JSON object with planet info or empty object if not found
# Usage: state_get "mercury"
state_get() {
    local planet="$1"

    state_init

    if command_exists jq; then
        jq -r --arg planet "$planet" '.installed[$planet] // empty' "$STATE_FILE"
    else
        # Fallback: grep-based parsing (slower, but works without jq)
        grep -A 10 "\"$planet\"" "$STATE_FILE" 2>/dev/null || echo "{}"
    fi
}

# state_list: List all installed planets
# Returns array of planet names
# Usage: state_list
state_list() {
    state_init

    if command_exists jq; then
        jq -r '.installed | keys[]' "$STATE_FILE" 2>/dev/null || echo "[]"
    else
        # Fallback: simple grep
        grep -o '"[^"]*"' "$STATE_FILE" 2>/dev/null | grep -v "version\|installed" | tr -d '"' | sort -u
    fi
}

# state_get_version: Get version of installed planet
# Usage: state_get_version "mercury"
state_get_version() {
    local planet="$1"

    if command_exists jq; then
        jq -r --arg planet "$planet" '.installed[$planet].version // "unknown"' "$STATE_FILE"
    else
        grep -o "\"$planet\"" "$STATE_FILE" >/dev/null && echo "installed" || echo "unknown"
    fi
}

# state_is_installed: Check if planet is installed
# Returns: 0 if installed, 1 if not
# Usage: if state_is_installed "mercury"; then ...; fi
state_is_installed() {
    local planet="$1"

    state_init

    if command_exists jq; then
        local installed
        installed=$(jq -r --arg planet "$planet" '.installed | has($planet)' "$STATE_FILE")
        [[ "$installed" == "true" ]]
    else
        # Fallback: check if planet name exists in state file
        grep -q "\"$planet\"" "$STATE_FILE" 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATE WRITE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# state_add: Add or update a planet in the state
# Usage: state_add "mercury" "1.0.0" "/path/to/checksum"
state_add() {
    local planet="$1"
    local version="${2:-"unknown"}"
    local checksum="${3:-""}"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    state_init
    state_lock

    local temp_file="${STATE_FILE}.tmp"

    if command_exists jq; then
        # Use jq for safe JSON manipulation
        jq --arg planet "$planet" \
           --arg version "$version" \
           --arg timestamp "$timestamp" \
           --arg checksum "$checksum" \
           '
           .installed[$planet] = {
               version: $version,
               installed_at: $timestamp,
               checksum: $checksum
           } |
           .last_update = $timestamp
           ' "$STATE_FILE" > "$temp_file" && mv "$temp_file" "$STATE_FILE"
    else
        # Fallback: manual JSON construction (less safe)
        error "jq is required for state management. Install with: brew install jq"
        state_unlock
        return 1
    fi

    state_unlock
    log "Added planet to state: $planet (v$version)"
    return 0
}

# state_remove: Remove a planet from the state
# Usage: state_remove "mercury"
state_remove() {
    local planet="$1"

    state_init
    state_lock

    if ! state_is_installed "$planet"; then
        warn "Planet not in state: $planet"
        state_unlock
        return 0
    fi

    local temp_file="${STATE_FILE}.tmp"

    if command_exists jq; then
        jq --arg planet "$planet" '
           del(.installed[$planet]) |
           .last_update = now | todate
        ' "$STATE_FILE" > "$temp_file" && mv "$temp_file" "$STATE_FILE"
    else
        error "jq is required for state management. Install with: brew install jq"
        state_unlock
        return 1
    fi

    state_unlock
    log "Removed planet from state: $planet"
    return 0
}

# state_update_checksum: Update checksum for a planet
# Usage: state_update_checksum "mercury" "abc123def"
state_update_checksum() {
    local planet="$1"
    local checksum="$2"

    state_init
    state_lock

    if ! state_is_installed "$planet"; then
        error "Cannot update checksum: planet not installed: $planet"
        state_unlock
        return 1
    fi

    local temp_file="${STATE_FILE}.tmp"

    if command_exists jq; then
        jq --arg planet "$planet" --arg checksum "$checksum" \
           '.installed[$planet].checksum = $checksum' \
           "$STATE_FILE" > "$temp_file" && mv "$temp_file" "$STATE_FILE"
    else
        error "jq is required for state management"
        state_unlock
        return 1
    fi

    state_unlock
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATE QUERY OPERATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# state_count: Count number of installed planets
# Usage: state_count
state_count() {
    state_init

    if command_exists jq; then
        jq '.installed | length' "$STATE_FILE"
    else
        state_list | wc -l
    fi
}

# state_last_update: Get timestamp of last state update
# Usage: state_last_update
state_last_update() {
    state_init

    if command_exists jq; then
        jq -r '.last_update // "never"' "$STATE_FILE"
    else
        stat -c %y "$STATE_FILE" 2>/dev/null || stat -f %Sm "$STATE_FILE" 2>/dev/null || echo "unknown"
    fi
}

# state_export: Export state to JSON string
# Usage: state_export
state_export() {
    state_init
    cat "$STATE_FILE"
}

# state_import: Import state from JSON string
# Usage: state_import '{"installed":{...}}'
state_import() {
    local json="$1"

    # Validate JSON
    if ! echo "$json" | jq empty 2>/dev/null; then
        error "Invalid JSON provided"
        return 1
    fi

    state_lock
    echo "$json" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    state_unlock

    log "State imported successfully"
    return 0
}

# state_validate: Validate state file integrity
# Returns: 0 if valid, 1 if invalid
# Usage: state_validate
state_validate() {
    state_init

    if [[ ! -f "$STATE_FILE" ]]; then
        error "State file does not exist"
        return 1
    fi

    if command_exists jq; then
        if ! jq empty "$STATE_FILE" 2>/dev/null; then
            error "State file is not valid JSON"
            return 1
        fi

        # Check required fields
        if ! jq -e '.version' "$STATE_FILE" >/dev/null; then
            error "State file missing 'version' field"
            return 1
        fi

        if ! jq -e '.installed' "$STATE_FILE" >/dev/null; then
            error "State file missing 'installed' field"
            return 1
        fi
    fi

    return 0
}

# state_backup: Create backup of state file
# Usage: state_backup
state_backup() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${STATE_FILE}.backup_${timestamp}"

    state_init

    cp "$STATE_FILE" "$backup_file"
    log "State backed up to: $backup_file"

    echo "$backup_file"
}

# state_restore: Restore state from backup
# Usage: state_restore "/path/to/backup"
state_restore() {
    local backup_file="$1"

    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
        return 1
    fi

    # Validate backup
    if ! jq empty "$backup_file" 2>/dev/null; then
        error "Backup file is not valid JSON"
        return 1
    fi

    state_lock
    cp "$backup_file" "$STATE_FILE"
    state_unlock

    log "State restored from: $backup_file"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

export -f state_init state_lock state_unlock
export -f state_get state_list state_get_version state_is_installed
export -f state_add state_remove state_update_checksum
export -f state_count state_last_update state_export state_import state_validate
export -f state_backup state_restore
