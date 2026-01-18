#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Venus
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Editors & IDEs - Development environments
# Duration: ~10 min
# Dependencies: mercury
#
# Tools:
#   - Neovim 0.11+: Modern vim-based editor
#   - LazyVim: Pre-configured Neovim distro
#   - JetBrains Mono: Beautiful coding font
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

PLANET_NAME="venus"
PLANET_VERSION="1.0.0"
PLANET_DESC="Editors & IDEs - Neovim 0.11+ with LazyVim config"

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
  "duration": "10 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # Venus depends on Mercury for terminal tools
    echo "mercury"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# check_homebrew: Ensure Homebrew is installed
check_homebrew() {
    if ! command_exists brew; then
        error "Homebrew is not installed"
        log "Please install Homebrew first:"
        log "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    return 0
}

# install_neovim: Install Neovim 0.11+ from Homebrew
install_neovim() {
    step "Installing Neovim 0.11+"

    if command_exists nvim; then
        log "Neovim already installed"
        local version
        version=$(nvim --version | head -n1)
        log "Current version: $version"

        # Check if it's 0.11+
        if nvim --version | grep -q "NVIM v0\.1[1-9]\|NVIM v0\.[2-9]\|NVIM v[1-9]"; then
            success "Neovim 0.11+ already installed"
            return 0
        else
            warn "Neovim version is too old, upgrading..."
            brew upgrade neovim
            success "Neovim upgraded"
        fi
    else
        brew install neovim
        success "Neovim installed"
    fi
}

# install_lazyvim: Install and configure LazyVim
install_lazyvim() {
    step "Installing LazyVim configuration"

    local nvim_config="$HOME/.config/nvim"
    local nvim_data="$HOME/.local/share/nvim"

    # Backup existing config if present
    if [[ -d "$nvim_config" ]]; then
        log "Existing nvim config found, backing up"
        local backup_path="${nvim_config}.bak.$(date +%s)"
        mv "$nvim_config" "$backup_path"
        log "Backed up to: $backup_path"
    fi

    # Backup existing data if present
    if [[ -d "$nvim_data" ]]; then
        log "Existing nvim data found, backing up"
        local backup_path="${nvim_data}.bak.$(date +%s)"
        mv "$nvim_data" "$backup_path"
        log "Backed up to: $backup_path"
    fi

    # Clone LazyVim starter config
    log "Cloning LazyVim starter configuration..."
    git clone https://github.com/LazyVim/starter "$nvim_config"
    rm -rf "${nvim_config}/.git"

    success "LazyVim installed"
}

# install_jetbrains_font: Install JetBrains Mono font (optional)
install_jetbrains_font() {
    step "Installing JetBrains Mono font (optional)"

    local font_dir="$HOME/.local/share/fonts"
    local font_name="JetBrainsMono"

    # Check if font is already installed
    if fc-list | grep -qi "JetBrains Mono"; then
        log "JetBrains Mono font already installed"
        return 0
    fi

    # Create font directory
    ensure_dir "$font_dir"

    # Download and install font
    local temp_dir="/tmp/jetbrains-mono-$$"
    mkdir -p "$temp_dir"

    log "Downloading JetBrains Mono font..."
    local font_url="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"

    if command_exists wget; then
        wget -q "$font_url" -O "$temp_dir/jetbrains.zip"
    elif command_exists curl; then
        curl -sL "$font_url" -o "$temp_dir/jetbrains.zip"
    else
        warn "Neither wget nor curl available, skipping font installation"
        rm -rf "$temp_dir"
        return 0
    fi

    # Unzip fonts
    unzip -q "$temp_dir/jetbrains.zip" -d "$temp_dir"

    # Install fonts
    find "$temp_dir/fonts/ttf" -name "*.ttf" -exec cp {} "$font_dir/" \;

    # Refresh font cache
    if command_exists fc-cache; then
        fc-cache -f "$font_dir" &>/dev/null || true
    fi

    # Cleanup
    rm -rf "$temp_dir"

    success "JetBrains Mono font installed"
}

# configure_shell_aliases: Add convenient aliases
configure_shell_aliases() {
    step "Adding shell aliases"

    local aliases_file="$HOME/.vibe-palace/venus_aliases.sh"

    cat > "$aliases_file" << 'ALIASES'
# Vibe Palace - Venus Editor Aliases
alias v='nvim'
alias vim='nvim'
alias vimrc='nvim ~/.config/nvim'
ALIASES

    success "Shell aliases created"
    log ""
    log "Add the following to your ~/.bashrc or ~/.zshrc:"
    log "  source ~/.vibe-palace/venus_aliases.sh"
}

# planet_install: Main installation logic
planet_install() {
    banner "🌍 VENUS: Editors & IDEs"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Venus already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install Neovim
    install_neovim

    # Install LazyVim
    install_lazyvim

    # Install JetBrains Mono font
    install_jetbrains_font

    # Configure shell aliases
    configure_shell_aliases

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Venus installation complete!"
    log ""
    log "Next steps:"
    log "  1. Open Neovim to install plugins:"
    log "     nvim"
    log "  2. Wait for LazyVim to install plugins (first launch)"
    log "  3. Source aliases in your shell config:"
    log "     source ~/.vibe-palace/venus_aliases.sh"
    log "  4. Start coding with 'v' or 'nvim'"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🌍 Uninstalling Venus"

    # Check if installed
    if ! planet_is_installed; then
        warn "Venus not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Venus tools"

    # Remove Neovim via Homebrew
    if brew list neovim &>/dev/null; then
        log "Uninstalling Neovim..."
        brew uninstall neovim 2>/dev/null || true
        success "Neovim removed"
    fi

    # Backup and remove configs
    step "Backing up configs"
    local backup_dir="$VIBE_DIR/venus_backup_$(date +%s)"

    if [[ -d "$HOME/.config/nvim" ]]; then
        ensure_dir "$backup_dir"
        cp -r "$HOME/.config/nvim" "$backup_dir/"
        rm -rf "$HOME/.config/nvim"
        log "Backed up and removed: ~/.config/nvim"
    fi

    if [[ -d "$HOME/.local/share/nvim" ]]; then
        ensure_dir "$backup_dir"
        cp -r "$HOME/.local/share/nvim" "$backup_dir/" 2>/dev/null || true
        rm -rf "$HOME/.local/share/nvim"
        log "Backed up and removed: ~/.local/share/nvim"
    fi

    if [[ -d "$HOME/.local/state/nvim" ]]; then
        rm -rf "$HOME/.local/state/nvim"
        log "Removed: ~/.local/state/nvim"
    fi

    if [[ -d "$HOME/.cache/nvim" ]]; then
        rm -rf "$HOME/.cache/nvim"
        log "Removed: ~/.cache/nvim"
    fi

    # Remove aliases file
    if [[ -f "$HOME/.vibe-palace/venus_aliases.sh" ]]; then
        rm -f "$HOME/.vibe-palace/venus_aliases.sh"
        log "Removed: venus_aliases.sh"
    fi

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Venus uninstalled"
    log "Configs backed up to: $backup_dir"
    log ""
    log "NOTE: Mercury (terminal tools) was NOT removed"
    log "      Each planet is independent!"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Venus health..."

    # Check Neovim binary
    if command_exists nvim; then
        local version
        version=$(nvim --version | head -n1)
        success "Neovim installed: $version"

        # Check version is 0.11+
        if nvim --version | grep -q "NVIM v0\.1[1-9]\|NVIM v0\.[2-9]\|NVIM v[1-9]"; then
            success "Neovim version is 0.11+"
        else
            error "Neovim version is too old (need 0.11+)"
            ((failed++))
        fi
    else
        error "Neovim not found in PATH"
        ((failed++))
    fi

    # Check LazyVim config
    if [[ -d "$HOME/.config/nvim" ]]; then
        success "Neovim config directory exists"

        # Check for LazyVim markers
        if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
            if grep -q "LazyVim" "$HOME/.config/nvim/init.lua" 2>/dev/null; then
                success "LazyVim configuration detected"
            else
                warn "init.lua exists but doesn't look like LazyVim"
            fi
        else
            error "init.lua not found"
            ((failed++))
        fi
    else
        error "Neovim config directory not found"
        ((failed++))
    fi

    # Check for LazyVim plugin data
    if [[ -d "$HOME/.local/share/nvim" ]]; then
        success "Neovim data directory exists"
    else
        warn "Neovim data directory not found (will be created on first run)"
    fi

    # Check aliases file
    if [[ -f "$HOME/.vibe-palace/venus_aliases.sh" ]]; then
        success "Shell aliases file exists"
    else
        warn "Shell aliases file not found"
    fi

    # Check state
    if state_is_installed "$PLANET_NAME"; then
        success "State registered"
    else
        error "State not registered"
        ((failed++))
    fi

    # Summary
    echo ""
    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issue(s)"
        return 1
    fi

    success "Venus is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists nvim && \
        [[ -d "$HOME/.config/nvim" ]] && \
        [[ -f "$HOME/.config/nvim/init.lua" ]] && \
        state_is_installed "$PLANET_NAME"
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
