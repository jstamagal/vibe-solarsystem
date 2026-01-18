#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Pluto
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Bonus Tools - Extra utilities and enhancements
# Duration: ~5 min
# Dependencies: mercury
#
# Tools:
#   - Zsh + Oh My Zsh
#   - Zsh plugins (autosuggestions, syntax-highlighting, completions)
#   - Shell enhancements
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

PLANET_NAME="pluto"
PLANET_VERSION="1.0.0"
PLANET_DESC="Bonus Tools - Zsh, Oh My Zsh, shell plugins"

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
  "duration": "5 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # Pluto depends on Mercury for terminal tools
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

# install_zsh: Install Zsh
install_zsh() {
    step "Installing Zsh"

    if command_exists zsh; then
        local zsh_version
        zsh_version=$(zsh --version 2>/dev/null || echo "unknown")
        log "Zsh already installed: $zsh_version"
        return 0
    fi

    brew install zsh
    success "Zsh installed"
}

# install_oh_my_zsh: Install Oh My Zsh
install_oh_my_zsh() {
    step "Installing Oh My Zsh"

    local omz_dir="$HOME/.oh-my-zsh"

    if [[ -d "$omz_dir" ]]; then
        log "Oh My Zsh already installed"
        return 0
    fi

    # Install Oh My Zsh unattended
    if command_exists curl; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"
    elif command_exists wget; then
        sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"
    else
        error "Neither curl nor wget available"
        return 1
    fi
}

# install_zsh_plugins: Install Zsh plugins
install_zsh_plugins() {
    step "Installing Zsh plugins"

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Create plugins directory
    ensure_dir "$zsh_custom/plugins"

    # Install zsh-autosuggestions
    if [[ -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        log "zsh-autosuggestions already installed"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" 2>/dev/null || true
        success "zsh-autosuggestions installed"
    fi

    # Install zsh-syntax-highlighting
    if [[ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        log "zsh-syntax-highlighting already installed"
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting" 2>/dev/null || true
        success "zsh-syntax-highlighting installed"
    fi

    # Install zsh-completions
    if [[ -d "$zsh_custom/plugins/zsh-completions" ]]; then
        log "zsh-completions already installed"
    else
        git clone https://github.com/zsh-users/zsh-completions "$zsh_custom/plugins/zsh-completions" 2>/dev/null || true
        success "zsh-completions installed"
    fi
}

# configure_zsh: Create Zsh configuration
configure_zsh() {
    step "Configuring Zsh"

    local zshrc_file="$HOME/.zshrc"

    # Backup existing .zshrc
    if [[ -f "$zshrc_file" ]]; then
        log "Existing .zshrc found, backing up"
        cp "$zshrc_file" "${zshrc_file}.backup_$(date +%s)"
    fi

    # Get planet integration files
    local mercury_integration="$HOME/.vibe-palace/mercury_integration.sh"
    local mars_integration="$HOME/.vibe-palace/mars_fnm.sh"
    local mars_pyenv="$HOME/.vibe-palace/mars_pyenv.sh"
    local mars_rust="$HOME/.vibe-palace/mars_rust.sh"
    local mars_golang="$HOME/.vibe-palace/mars_golang.sh"
    local venus_aliases="$HOME/.vibe-palace/venus_aliases.sh"
    local uranus_aliases="$HOME/.vibe-palace/uranus_aliases.sh"
    local saturn_aliases="$HOME/.vibe-palace/saturn_aliases.sh"
    local neptune_aliases="$HOME/.vibe-palace/neptune_aliases.sh"

    cat > "$zshrc_file" << 'ZSHRC'
# ═══════════════════════════════════════════════════════════════════════════════
# VIBE PALACE ZSH CONFIG
# ═══════════════════════════════════════════════════════════════════════════════

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# ═══════════════════════════════════════════════════════════════════════════════
# PLUGINS
# ═══════════════════════════════════════════════════════════════════════════════

plugins=(
    git
    docker
    npm
    node
    python
    rust
    golang
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# ═══════════════════════════════════════════════════════════════════════════════
# OH MY ZSH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

source \$ZSH/oh-my-zsh.sh

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET INTEGRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Starship prompt (overrides Oh My Zsh theme)
eval "\$(starship init zsh)"

# Zoxide
eval "\$(zoxide init zsh)"

# Homebrew
eval "\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ═══════════════════════════════════════════════════════════════════════════════
# LANGUAGE RUNTIMES (if Mars is installed)
# ═══════════════════════════════════════════════════════════════════════════════

# fnm (Node.js) - if installed
if [[ -f "$HOME/.vibe-palace/mars_fnm.sh" ]]; then
    source "$HOME/.vibe-palace/mars_fnm.sh"
fi

# pyenv (Python) - if installed
if [[ -f "$HOME/.vibe-palace/mars_pyenv.sh" ]]; then
    source "$HOME/.vibe-palace/mars_pyenv.sh"
fi

# Rust - if installed
if [[ -f "$HOME/.vibe-palace/mars_rust.sh" ]]; then
    source "$HOME/.vibe-palace/mars_rust.sh"
fi

# Go - if installed
if [[ -f "$HOME/.vibe-palace/mars_golang.sh" ]]; then
    source "$HOME/.vibe-palace/mars_golang.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET ALIASES (if installed)
# ═══════════════════════════════════════════════════════════════════════════════

# Venus (Editor aliases)
if [[ -f "$HOME/.vibe-palace/venus_aliases.sh" ]]; then
    source "$HOME/.vibe-palace/venus_aliases.sh"
fi

# Uranus (Dev tools aliases)
if [[ -f "$HOME/.vibe-palace/uranus_aliases.sh" ]]; then
    source "$HOME/.vibe-palace/uranus_aliases.sh"
fi

# Saturn (AI tools aliases)
if [[ -f "$HOME/.vibe-palace/saturn_aliases.sh" ]]; then
    source "$HOME/.vibe-palace/saturn_aliases.sh"
fi

# Neptune (Container aliases)
if [[ -f "$HOME/.vibe-palace/neptune_aliases.sh" ]]; then
    source "$HOME/.vibe-palace/neptune_aliases.sh"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# ADDITIONAL ALIASES
# ═══════════════════════════════════════════════════════════════════════════════

# Modern replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'

# Quick edits
alias zshrc='nvim ~/.zshrc'
alias vimrc='nvim ~/.config/nvim'
alias tmuxrc='nvim ~/.tmux.conf'

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick project setup
newproject() {
    mkcd "$HOME/projects/$1"
    git init
    echo "# $1" > README.md
    echo "node_modules/" > .gitignore
    echo ".env" >> .gitignore
}

# FZF file opener
vf() {
    local file
    file=$(fzf --preview 'bat --color=always {}')
    [[ -n "$file" ]] && nvim "$file"
}

# FZF directory changer
cdf() {
    local dir
    dir=$(fd --type d | fzf --preview 'eza --tree --level=1 {}')
    [[ -n "$dir" ]] && cd "$dir"
}

ZSHRC

    success "Zsh configured"
}

# set_default_shell: Set Zsh as default shell
set_default_shell() {
    step "Setting Zsh as default shell"

    # Check if zsh is in /etc/shells
    if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
        log "Adding zsh to /etc/shells (requires sudo)"
        if command_exists sudo; then
            echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null || true
        fi
    fi

    # Change default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log "Changing default shell to zsh..."
        chsh -s "$(which zsh)" 2>/dev/null || {
            warn "Could not change default shell"
            log "Run manually: chsh -s $(which zsh)"
        }
        success "Default shell changed to zsh"
    else
        log "Zsh is already the default shell"
    fi
}

# planet_install: Main installation logic
planet_install() {
    banner "☄️ PLUTO: Bonus Tools"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Pluto already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install Zsh
    install_zsh

    # Install Oh My Zsh
    install_oh_my_zsh

    # Install Zsh plugins
    install_zsh_plugins

    # Configure Zsh
    configure_zsh

    # Set default shell
    set_default_shell

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Pluto installation complete!"
    log ""
    log "Installed tools:"
    log "  • Zsh"
    log "  • Oh My Zsh"
    log "  • Zsh plugins (autosuggestions, syntax-highlighting, completions)"
    log ""
    log "Next steps:"
    log "  1. Start a new Zsh session:"
    log "     exec zsh"
    log ""
    log "  2. Or logout and login to use Zsh as your default shell"
    log ""
    log "  3. Your .zshrc includes integrations with other planets:"
    log "     - Starship prompt (Mercury)"
    log "     - Zoxide (Mercury)"
    log "     - Language runtimes (Mars, if installed)"
    log "     - Planet aliases (Venus, Uranus, Saturn, Neptune)"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "☄️ Uninstalling Pluto"

    # Check if installed
    if ! planet_is_installed; then
        warn "Pluto not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Pluto tools"

    # Remove Zsh via Homebrew (but not if it's the current shell)
    if [[ "$SHELL" != *"zsh"* ]]; then
        if brew list zsh &>/dev/null; then
            log "Uninstalling Zsh..."
            brew uninstall zsh 2>/dev/null || true
            success "Zsh removed"
        fi
    else
        warn "Cannot remove Zsh (it's your current shell)"
        log "To uninstall Zsh, first switch to another shell:"
        log "  chsh -s /bin/bash"
        log "Then run: vibe uninstall pluto"
    fi

    # Backup and remove Oh My Zsh
    step "Backing up Oh My Zsh configuration"
    local backup_dir="$VIBE_DIR/pluto_backup_$(date +%s)"

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ensure_dir "$backup_dir"
        cp -r "$HOME/.oh-my-zsh" "$backup_dir/" 2>/dev/null || true
        rm -rf "$HOME/.oh-my-zsh"
        log "Backed up and removed: ~/.oh-my-zsh"
    fi

    # Backup .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        ensure_dir "$backup_dir"
        cp "$HOME/.zshrc" "$backup_dir/"
        log "Backed up: ~/.zshrc"

        # Restore backup if it exists
        if [[ -f "${HOME}/.zshrc.backup_"* ]]; then
            local latest_backup
            latest_backup=$(ls -t ~/.zshrc.backup_* 2>/dev/null | head -n1)
            if [[ -n "$latest_backup" ]]; then
                log "Restoring previous .zshrc backup..."
                cp "$latest_backup" "$HOME/.zshrc"
            fi
        fi
    fi

    # Remove Zsh plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        rm -rf "$zsh_custom/plugins/zsh-autosuggestions"
        log "Removed: zsh-autosuggestions"
    fi

    if [[ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        rm -rf "$zsh_custom/plugins/zsh-syntax-highlighting"
        log "Removed: zsh-syntax-highlighting"
    fi

    if [[ -d "$zsh_custom/plugins/zsh-completions" ]]; then
        rm -rf "$zsh_custom/plugins/zsh-completions"
        log "Removed: zsh-completions"
    fi

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Pluto uninstalled"
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

    echo "Checking Pluto health..."

    # Check Zsh
    if command_exists zsh; then
        local zsh_version
        zsh_version=$(zsh --version 2>/dev/null || echo "unknown")
        success "Zsh installed: $zsh_version"
    else
        error "Zsh not found in PATH"
        ((failed++))
    fi

    # Check Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh installed"
    else
        error "Oh My Zsh not found"
        ((failed++))
    fi

    # Check Zsh plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        success "zsh-autosuggestions installed"
    else
        warn "zsh-autosuggestions not found"
    fi

    if [[ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        success "zsh-syntax-highlighting installed"
    else
        warn "zsh-syntax-highlighting not found"
    fi

    if [[ -d "$zsh_custom/plugins/zsh-completions" ]]; then
        success "zsh-completions installed"
    else
        warn "zsh-completions not found"
    fi

    # Check .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        success ".zshrc exists"

        # Check if it sources Oh My Zsh
        if grep -q "oh-my-zsh" "$HOME/.zshrc" 2>/dev/null; then
            success ".zshrc configured for Oh My Zsh"
        else
            warn ".zshrc doesn't seem to configure Oh My Zsh"
        fi
    else
        error ".zshrc not found"
        ((failed++))
    fi

    # Check if Zsh is default shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        success "Zsh is set as default shell"
    else
        warn "Zsh is not the default shell"
    fi

    # Check state
    echo ""
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

    success "Pluto is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists zsh && \
        [[ -d "$HOME/.oh-my-zsh" ]] && \
        [[ -f "$HOME/.zshrc" ]] && \
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
