#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Backup & Restore Library
# ═══════════════════════════════════════════════════════════════════════════════
# Manages backup creation, restoration, and validation for Vibe Palace
# Supports: full backups, config-only backups, cross-machine migration
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Source core library if not already loaded
if [[ -z "${VIBE_DIR:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/core.sh"
    source "$SCRIPT_DIR/state.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

export BACKUP_DIR="${BACKUP_DIR:-$VIBE_DIR/backups}"
export BACKUP_MANIFEST="manifest.json"
export BACKUP_STATE="state.json"
export BACKUP_CONFIGS_TAR="configs.tar.gz"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# backup_get_filename: Generate backup filename with timestamp
# Usage: backup_get_filename
backup_get_filename() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    echo "vibe-backup-${timestamp}.tar.gz"
}

# backup_get_temp_dir: Create temporary directory for backup operations
# Usage: backup_get_temp_dir
backup_get_temp_dir() {
    mktemp -d -t vibe-backup-XXXXXX
}

# backup_calculate_checksum: Calculate SHA256 checksum of a file
# Usage: backup_calculate_checksum "file.txt"
backup_calculate_checksum() {
    local file="$1"

    if command_exists sha256sum; then
        sha256sum "$file" | awk '{print $1}'
    elif command_exists shasum; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        warn "SHA256 tool not available, skipping checksum"
        echo "unknown"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP CREATION
# ═══════════════════════════════════════════════════════════════════════════════

# backup_collect_configs: Collect all config files for backup
# Usage: backup_collect_configs "$temp_dir"
backup_collect_configs() {
    local temp_dir="$1"
    local configs_dir="$temp_dir/configs"

    mkdir -p "$configs_dir"

    log "Collecting configuration files..."

    # Common config directories to backup
    local config_paths=(
        "$HOME/.config/starship.toml"
        "$HOME/.config/nvim"
        "$HOME/.config/helix"
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.fzf.zsh"
        "$HOME/.fzf.bash"
    )

    # Copy each config if it exists
    for config_path in "${config_paths[@]}"; do
        if [[ -e "$config_path" ]]; then
            local rel_path="${config_path#$HOME/}"
            local dest="$configs_dir/$rel_path"
            mkdir -p "$(dirname "$dest")"

            if cp -r "$config_path" "$dest" 2>/dev/null; then
                log_verbose "Backed up: $rel_path"
            fi
        fi
    done

    success "Configuration files collected"
}

# backup_create_manifest: Create backup manifest with metadata
# Usage: backup_create_manifest "$temp_dir"
backup_create_manifest() {
    local temp_dir="$1"
    local manifest_file="$temp_dir/$BACKUP_MANIFEST"

    log "Creating backup manifest..."

    # Get installed planets with versions
    local planets_json=""
    if command_exists jq && [[ -f "$STATE_FILE" ]]; then
        planets_json=$(jq -c '.installed' "$STATE_FILE" 2>/dev/null || echo '{}')
    else
        planets_json='{}'
    fi

    # Create manifest JSON
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local hostname
    hostname=$(hostname 2>/dev/null || echo "unknown")
    local username
    username=$(whoami 2>/dev/null || echo "unknown")
    local os
    os=$(get_os)
    local arch
    arch=$(get_arch)

    cat > "$manifest_file" <<EOF
{
  "version": "1.0",
  "type": "vibe-backup",
  "created_at": "$timestamp",
  "hostname": "$hostname",
  "username": "$username",
  "os": "$os",
  "arch": "$arch",
  "planets": $planets_json,
  "vibe_version": "1.0.0"
}
EOF

    success "Backup manifest created"
}

# backup_create_internal: Internal backup creation function
# Usage: backup_create_internal "$temp_dir" "$include_state"
backup_create_internal() {
    local temp_dir="$1"
    local include_state="${2:-true}"

    # Collect configs
    backup_collect_configs "$temp_dir"

    # Copy state file if requested
    if [[ "$include_state" == "true" ]] && [[ -f "$STATE_FILE" ]]; then
        log "Backing up state file..."
        cp "$STATE_FILE" "$temp_dir/$BACKUP_STATE"
        success "State file backed up"
    fi

    # Create manifest
    backup_create_manifest "$temp_dir"
}

# backup_create: Create a full backup (configs + state)
# Usage: backup_create [output_file]
# Returns: Path to created backup file
backup_create() {
    local output_file="${1:-}"
    local temp_dir
    temp_dir=$(backup_get_temp_dir)

    log "Creating full backup..."

    # Create backup content
    backup_create_internal "$temp_dir" "true"

    # Generate output filename if not provided
    if [[ -z "$output_file" ]]; then
        output_file="$BACKUP_DIR/$(backup_get_filename)"
    else
        # Ensure backup directory exists in output path
        mkdir -p "$(dirname "$output_file")"
    fi

    # Create tarball
    log "Compressing backup..."
    if tar -czf "$output_file" -C "$temp_dir" . 2>/dev/null; then
        success "Backup created: $output_file"

        # Calculate checksum
        local checksum
        checksum=$(backup_calculate_checksum "$output_file")
        if [[ "$checksum" != "unknown" ]]; then
            log "SHA256: $checksum"
            echo "$checksum" > "${output_file}.sha256"
        fi

        # Cleanup temp dir
        rm -rf "$temp_dir"

        echo "$output_file"
        return 0
    else
        error "Failed to create backup archive"
        rm -rf "$temp_dir"
        return 1
    fi
}

# backup_configs_only: Create a config-only backup (no state)
# Usage: backup_configs_only [output_file]
# Returns: Path to created backup file
backup_configs_only() {
    local output_file="${1:-}"
    local temp_dir
    temp_dir=$(backup_get_temp_dir)

    log "Creating config-only backup..."

    # Create backup content (without state)
    backup_create_internal "$temp_dir" "false"

    # Generate output filename if not provided
    if [[ -z "$output_file" ]]; then
        output_file="$BACKUP_DIR/vibe-configs-$(date '+%Y%m%d_%H%M%S').tar.gz"
    else
        mkdir -p "$(dirname "$output_file")"
    fi

    # Create tarball
    log "Compressing backup..."
    if tar -czf "$output_file" -C "$temp_dir" . 2>/dev/null; then
        success "Config backup created: $output_file"

        # Calculate checksum
        local checksum
        checksum=$(backup_calculate_checksum "$output_file")
        if [[ "$checksum" != "unknown" ]]; then
            log "SHA256: $checksum"
            echo "$checksum" > "${output_file}.sha256"
        fi

        # Cleanup temp dir
        rm -rf "$temp_dir"

        echo "$output_file"
        return 0
    else
        error "Failed to create backup archive"
        rm -rf "$temp_dir"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

# backup_validate: Validate backup file integrity
# Usage: backup_validate "backup_file.tar.gz"
# Returns: 0 if valid, 1 if invalid
backup_validate() {
    local backup_file="$1"

    log "Validating backup: $backup_file"

    # Check if file exists
    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
        return 1
    fi

    # Check if it's a tar.gz file
    if ! tar -tzf "$backup_file" >/dev/null 2>&1; then
        error "Invalid backup format (not a valid tar.gz file)"
        return 1
    fi

    # Extract and validate manifest
    local temp_dir
    temp_dir=$(backup_get_temp_dir)

    if ! tar -xzf "$backup_file" -C "$temp_dir" 2>/dev/null; then
        error "Failed to extract backup"
        rm -rf "$temp_dir"
        return 1
    fi

    local manifest_file="$temp_dir/$BACKUP_MANIFEST"

    if [[ ! -f "$manifest_file" ]]; then
        error "Backup manifest not found"
        rm -rf "$temp_dir"
        return 1
    fi

    # Validate manifest is valid JSON
    if ! jq empty "$manifest_file" 2>/dev/null; then
        error "Backup manifest is not valid JSON"
        rm -rf "$temp_dir"
        return 1
    fi

    # Check manifest version
    local version
    version=$(jq -r '.version // "unknown"' "$manifest_file" 2>/dev/null)
    if [[ "$version" == "unknown" ]]; then
        warn "Backup manifest missing version information"
    fi

    # Verify checksum if available
    local checksum_file="${backup_file}.sha256"
    if [[ -f "$checksum_file" ]]; then
        log "Verifying checksum..."
        local stored_checksum
        stored_checksum=$(cat "$checksum_file" 2>/dev/null | awk '{print $1}')
        local actual_checksum
        actual_checksum=$(backup_calculate_checksum "$backup_file")

        if [[ "$stored_checksum" == "$actual_checksum" ]]; then
            success "Checksum verified"
        else
            warn "Checksum mismatch!"
            warn "Expected: $stored_checksum"
            warn "Actual: $actual_checksum"
        fi
    fi

    rm -rf "$temp_dir"

    # Display backup info
    backup_show_info "$backup_file"

    success "Backup validation passed"
    return 0
}

# backup_show_info: Display information about a backup file
# Usage: backup_show_info "backup_file.tar.gz"
backup_show_info() {
    local backup_file="$1"

    local temp_dir
    temp_dir=$(backup_get_temp_dir)

    tar -xzf "$backup_file" -C "$temp_dir" 2>/dev/null

    local manifest_file="$temp_dir/$BACKUP_MANIFEST"

    if [[ -f "$manifest_file" ]]; then
        echo ""
        info "Backup Information:"

        local created_at
        local hostname
        local username
        local os
        local arch

        created_at=$(jq -r '.created_at // "unknown"' "$manifest_file")
        hostname=$(jq -r '.hostname // "unknown"' "$manifest_file")
        username=$(jq -r '.username // "unknown"' "$manifest_file")
        os=$(jq -r '.os // "unknown"' "$manifest_file")
        arch=$(jq -r '.arch // "unknown"' "$manifest_file")

        echo "  Created: $created_at"
        echo "  Host: $hostname"
        echo "  User: $username"
        echo "  OS: $os / $arch"

        # Show installed planets
        local planets
        planets=$(jq -r '.planets | keys[]' "$manifest_file" 2>/dev/null || echo "")

        if [[ -n "$planets" ]]; then
            echo "  Planets:"
            while IFS= read -r planet; do
                local version
                version=$(jq -r ".planets[$planet].version // \"unknown\"" "$manifest_file")
                echo "    • $planet (v$version)"
            done <<< "$planets"
        fi
        echo ""
    fi

    rm -rf "$temp_dir"
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP RESTORATION
# ═══════════════════════════════════════════════════════════════════════════════

# backup_restore: Restore from backup file
# Usage: backup_restore "backup_file.tar.gz" ["configs_only"]
backup_restore() {
    local backup_file="$1"
    local configs_only="${2:-false}"

    # Validate backup first
    if ! backup_validate "$backup_file"; then
        error "Backup validation failed"
        return 1
    fi

    local temp_dir
    temp_dir=$(backup_get_temp_dir)

    log "Extracting backup..."
    if ! tar -xzf "$backup_file" -C "$temp_dir" 2>/dev/null; then
        error "Failed to extract backup"
        rm -rf "$temp_dir"
        return 1
    fi

    # Check for manifest
    local manifest_file="$temp_dir/$BACKUP_MANIFEST"
    if [[ ! -f "$manifest_file" ]]; then
        error "Backup manifest not found"
        rm -rf "$temp_dir"
        return 1
    fi

    # Show what we're restoring
    backup_show_info "$backup_file"

    # Restore configs
    local configs_dir="$temp_dir/configs"
    if [[ -d "$configs_dir" ]]; then
        log "Restoring configuration files..."

        # Find all files in configs directory
        while IFS= read -r -d '' file; do
            local rel_path="${file#$configs_dir/}"
            local dest="$HOME/$rel_path"

            # Create destination directory
            mkdir -p "$(dirname "$dest")"

            # Backup existing file if it exists
            if [[ -e "$dest" ]]; then
                local backup_path="${dest}.backup_$(date +%s)"
                log "Backing up existing: $rel_path"
                cp -r "$dest" "$backup_path"
            fi

            # Restore file
            cp -r "$file" "$dest"
            log_verbose "Restored: $rel_path"

        done < <(find "$configs_dir" -type f -print0)

        success "Configuration files restored"
    fi

    # Restore state if requested and available
    if [[ "$configs_only" != "true" ]] && [[ -f "$temp_dir/$BACKUP_STATE" ]]; then
        log "Restoring state file..."

        # Backup current state
        if [[ -f "$STATE_FILE" ]]; then
            cp "$STATE_FILE" "${STATE_FILE}.backup_$(date +%s)"
        fi

        cp "$temp_dir/$BACKUP_STATE" "$STATE_FILE"
        success "State file restored"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    success "Restore complete!"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP LISTING
# ═══════════════════════════════════════════════════════════════════════════════

# backup_list: List all available backups
# Usage: backup_list
backup_list() {
    log "Available backups in: $BACKUP_DIR"

    if [[ ! -d "$BACKUP_DIR" ]]; then
        warn "No backups directory found"
        return 0
    fi

    local backups=()
    while IFS= read -r -d '' file; do
        backups+=("$file")
    done < <(find "$BACKUP_DIR" \( -name "vibe-backup-*.tar.gz" -o -name "vibe-configs-*.tar.gz" \) -type f -print0 2>/dev/null | sort -rz)

    if [[ ${#backups[@]} -eq 0 ]]; then
        warn "No backups found"
        return 0
    fi

    echo ""
    printf "  %-40s %-15s %s\n" "Filename" "Size" "Date"
    printf "  %-40s %-15s %s\n" "----------------------------------------" "---------------" "-------------------------"

    for backup in "${backups[@]}"; do
        local filename
        filename=$(basename "$backup")
        local size
        size=$(du -h "$backup" | awk '{print $1}')
        local date
        date=$(stat -c %y "$backup" 2>/dev/null | cut -d'.' -f1 || stat -f %Sm "$backup" 2>/dev/null || echo "unknown")

        printf "  %-40s %-15s %s\n" "$filename" "$size" "$date"
    done

    echo ""
    log "Total backups: ${#backups[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

export -f backup_get_filename backup_get_temp_dir backup_calculate_checksum
export -f backup_collect_configs backup_create_manifest backup_create_internal
export -f backup_create backup_configs_only
export -f backup_validate backup_show_info
export -f backup_restore
export -f backup_list
