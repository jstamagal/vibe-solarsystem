#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Example
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Example planet demonstrating the interface specification
# Duration: 1 min
# Dependencies: none
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get planet script directory
PLANET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core libraries
source "$PLANET_DIR/../lib/core.sh"
source "$PLANET_DIR/../lib/state.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET METADATA
# ═══════════════════════════════════════════════════════════════════════════════

PLANET_NAME="example"
PLANET_VERSION="1.0.0"
PLANET_DESC="Example planet for testing and reference"

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_metadata: Return information about this planet
planet_metadata() {
    cat <<EOF
{
  "name": "$PLANET_NAME",
  "version": "$PLANET_VERSION",
  "description": "$PLANET_DESC",
  "duration": "1 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # This planet has no dependencies
    echo ""
}

# planet_install: Main installation logic
planet_install() {
    banner "🪐 EXAMPLE: Example Planet Installation"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Example planet already installed, skipping..."
        return 0
    fi

    log "Installing example planet..."

    # Example: Create a marker file to simulate installation
    step "Creating example marker file"
    local marker_file="$VIBE_DIR/planets/$PLANET_NAME/marker.txt"
    ensure_dir "$(dirname "$marker_file")"
    echo "Example planet installed at $(date)" > "$marker_file"
    success "Marker file created"

    # Example: Create a sample config
    step "Creating example config"
    local config_dir="$HOME/.config/example"
    ensure_dir "$config_dir"
    cat > "$config_dir/config.toml" <<'CONFIG'
# Example config file
setting1 = "value1"
setting2 = 42
CONFIG
    success "Config created"

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Example planet installation complete"
    log "Planet location: $VIBE_DIR/planets/$PLANET_NAME"
    log "Config location: $config_dir"

    return 0
}

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🪐 Uninstalling Example Planet"

    # Check if installed
    if ! planet_is_installed; then
        warn "Example planet not installed, nothing to uninstall"
        return 0
    fi

    step "Removing example files"

    # Remove marker file
    local marker_file="$VIBE_DIR/planets/$PLANET_NAME/marker.txt"
    if [[ -f "$marker_file" ]]; then
        rm -f "$marker_file"
        log "Removed marker file"
    fi

    # Remove config directory
    local config_dir="$HOME/.config/example"
    if [[ -d "$config_dir" ]]; then
        rm -rf "$config_dir"
        log "Removed config directory"
    fi

    # Remove planet state directory
    local planet_dir="$VIBE_DIR/planets/$PLANET_NAME"
    if [[ -d "$planet_dir" ]]; then
        rm -rf "$planet_dir"
        log "Removed planet directory"
    fi

    # Update state
    state_remove "$PLANET_NAME"

    success "Example planet uninstalled"
    return 0
}

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Example planet health..."

    # Check marker file exists
    local marker_file="$VIBE_DIR/planets/$PLANET_NAME/marker.txt"
    if [[ -f "$marker_file" ]]; then
        success "Marker file exists"
    else
        error "Marker file missing: $marker_file"
        ((failed++))
    fi

    # Check config exists
    local config_file="$HOME/.config/example/config.toml"
    if [[ -f "$config_file" ]]; then
        success "Config file exists"
    else
        error "Config file missing: $config_file"
        ((failed++))
    fi

    # Check state
    if state_is_installed "$PLANET_NAME"; then
        success "State registered"
    else
        error "State not registered"
        ((failed++))
    fi

    # Summary
    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issue(s)"
        return 1
    fi

    success "Example planet is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Quick check: marker file and state registration
    local marker_file="$VIBE_DIR/planets/$PLANET_NAME/marker.txt"
    [[ -f "$marker_file" ]] && state_is_installed "$PLANET_NAME"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

# If script is executed directly (not sourced), run the requested function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        metadata)
            planet_metadata
            ;;
        dependencies)
            planet_dependencies
            ;;
        install)
            planet_install
            ;;
        uninstall)
            planet_uninstall
            ;;
        health)
            planet_check_health
            ;;
        is_installed)
            if planet_is_installed; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {metadata|dependencies|install|uninstall|health|is_installed}"
            echo ""
            echo "Commands:"
            echo "  metadata      Show planet metadata"
            echo "  dependencies  List planet dependencies"
            echo "  install       Install the planet"
            echo "  uninstall     Uninstall the planet"
            echo "  health        Run health check"
            echo "  is_installed  Check if installed"
            exit 1
            ;;
    esac
fi
