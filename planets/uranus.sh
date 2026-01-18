#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Uranus
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Dev Tools - Development utilities
# Duration: ~10 min
# Dependencies: mercury
#
# Tools:
#   - Git + lazygit + gh (GitHub CLI)
#   - jq, yq (JSON/YAML processors)
#   - httpie, curlie, xh (HTTP clients)
#   - gum, charmbracelet tools (beautiful CLI tools)
#   - just (task runner)
#   - Various dev utilities
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

PLANET_NAME="uranus"
PLANET_VERSION="1.0.0"
PLANET_DESC="Dev Tools - Git, lazygit, gh, jq, yq, httpie, gum, charmbracelet tools"

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
    # Uranus depends on Mercury for terminal tools
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

# install_git_tools: Install Git, lazygit, and GitHub CLI
install_git_tools() {
    step "Installing Git tools"

    # Check if Git is already installed (usually system package)
    if command_exists git; then
        local git_version
        git_version=$(git --version 2>/dev/null || echo "unknown")
        log "Git already installed: $git_version"
    else
        brew install git
        success "Git installed"
    fi

    # Install lazygit
    if command_exists lazygit; then
        log "lazygit already installed"
    else
        brew install lazygit
        success "lazygit installed"
    fi

    # Install GitHub CLI
    if command_exists gh; then
        log "GitHub CLI already installed"
    else
        brew install gh
        success "GitHub CLI installed"
    fi

    # Install git-lfs
    if command_exists git-lfs; then
        log "git-lfs already installed"
    else
        brew install git-lfs
        git lfs install
        success "git-lfs installed"
    fi
}

# configure_git: Configure Git with sensible defaults
configure_git() {
    step "Configuring Git"

    # Check if git is available
    if ! command_exists git; then
        error "Git not found"
        return 1
    fi

    # Configure delta as git pager (if installed from Mercury)
    if command_exists delta; then
        git config --global core.pager delta 2>/dev/null || true
        git config --global interactive.diffFilter "delta --color-only" 2>/dev/null || true
        git config --global delta.navigate true 2>/dev/null || true
        git config --global delta.light false 2>/dev/null || true
        git config --global delta.side-by-side true 2>/dev/null || true
        git config --global delta.line-numbers true 2>/dev/null || true
        git config --global merge.conflictstyle diff3 2>/dev/null || true
        git config --global diff.colorMoved default 2>/dev/null || true
        log "Configured Git to use delta pager"
    fi

    # Set useful aliases
    git config --global alias.co checkout 2>/dev/null || true
    git config --global alias.br branch 2>/dev/null || true
    git config --global alias.ci commit 2>/dev/null || true
    git config --global alias.st status 2>/dev/null || true
    git config --global alias.unstage 'reset HEAD --' 2>/dev/null || true
    git config --global alias.last 'log -1 HEAD' 2>/dev/null || true
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit" 2>/dev/null || true

    success "Git configured"
}

# install_json_tools: Install jq, yq, fx, jless
install_json_tools() {
    step "Installing JSON/YAML tools"

    if command_exists jq; then
        log "jq already installed"
    else
        brew install jq
        success "jq installed"
    fi

    if command_exists yq; then
        log "yq already installed"
    else
        brew install yq
        success "yq installed"
    fi

    # Optional JSON tools
    if command_exists fx; then
        log "fx already installed"
    else
        brew install fx 2>/dev/null || true
    fi

    if command_exists jless; then
        log "jless already installed"
    else
        brew install jless 2>/dev/null || true
    fi
}

# install_http_clients: Install httpie, curlie, xh
install_http_clients() {
    step "Installing HTTP clients"

    if command_exists http; then
        log "httpie already installed"
    else
        brew install httpie
        success "httpie installed"
    fi

    if command_exists curlie; then
        log "curlie already installed"
    else
        brew install curlie 2>/dev/null || true
    fi

    if command_exists xh; then
        log "xh already installed"
    else
        brew install xh 2>/dev/null || true
    fi
}

# install_charm_tools: Install gum and other charmbracelet tools
install_charm_tools() {
    step "Installing charmbracelet tools"

    if command_exists gum; then
        log "gum already installed"
    else
        brew install gum
        success "gum installed"
    fi

    # Optional charm tools
    local charm_tools=("gum" "charm" "glow" "gmarkdown")

    for tool in "${charm_tools[@]}"; do
        if command_exists "$tool"; then
            log "$tool already installed"
        else
            brew install "$tool" 2>/dev/null || true
        fi
    done

    success "charmbracelet tools installed"
}

# install_dev_utilities: Install additional dev utilities
install_dev_utilities() {
    step "Installing additional dev utilities"

    local utilities=(
        "just"          # Task runner
        "hyperfine"     # Benchmarking
        "tokei"         # Code counter
        "choose"        # Fuzzy selector
        "broot"         # file tree
        "lf"            # file manager
    )

    for util in "${utilities[@]}"; do
        if command_exists "$util"; then
            log "$util already installed"
        else
            log "Installing $util..."
            brew install "$util" 2>/dev/null || true
        fi
    done

    success "Dev utilities installed"
}

# configure_shell_aliases: Add convenient aliases
configure_shell_aliases() {
    step "Adding shell aliases"

    local aliases_file="$HOME/.vibe-palace/uranus_aliases.sh"

    cat > "$aliases_file" << 'ALIASES'
# Vibe Palace - Uranus Dev Tools Aliases

# Git
alias g='git'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'

# GitHub CLI
alias ghpr='gh pr create'
alias ghprv='gh pr view'
alias ghi='gh issue create'

# JSON/YAML
alias jq='jq'
alias yq='yq'

# HTTP clients
alias http='http'
alias curlie='curlie'

# Task runner
alias j='just'

# File management
alias broot='br'
ALIASES

    success "Shell aliases created"
    log ""
    log "Add the following to your ~/.bashrc or ~/.zshrc:"
    log "  source ~/.vibe-palace/uranus_aliases.sh"
}

# planet_install: Main installation logic
planet_install() {
    banner "💫 URANUS: Dev Tools"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Uranus already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install Git tools
    install_git_tools
    configure_git

    # Install JSON/YAML tools
    install_json_tools

    # Install HTTP clients
    install_http_clients

    # Install charm tools
    install_charm_tools

    # Install dev utilities
    install_dev_utilities

    # Configure shell aliases
    configure_shell_aliases

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Uranus installation complete!"
    log ""
    log "Installed tools:"
    log "  • Git + lazygit + gh (GitHub CLI)"
    log "  • jq, yq (JSON/YAML processors)"
    log "  • httpie, curlie, xh (HTTP clients)"
    log "  • gum, charmbracelet tools"
    log "  • just (task runner)"
    log "  • Additional dev utilities"
    log ""
    log "Next steps:"
    log "  1. Source aliases in your shell config:"
    log "     source ~/.vibe-palace/uranus_aliases.sh"
    log ""
    log "  2. Authenticate with GitHub:"
    log "     gh auth login"
    log ""
    log "  3. Try lazygit:"
    log "     lg"
    log ""
    log "  4. Try gum (interactive CLI tool):"
    log "     gum --help"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "💫 Uninstalling Uranus"

    # Check if installed
    if ! planet_is_installed; then
        warn "Uranus not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Uranus tools"

    # Remove tools via Homebrew
    local tools=(
        "lazygit"
        "gh"
        "git-lfs"
        "jq"
        "yq"
        "fx"
        "jless"
        "httpie"
        "curlie"
        "xh"
        "gum"
        "charm"
        "glow"
        "just"
        "hyperfine"
        "tokei"
        "choose"
        "broot"
        "lf"
    )

    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            log "Uninstalling $tool..."
            brew uninstall "$tool" 2>/dev/null || true
            success "$tool removed"
        fi
    done

    # Note: We don't remove git itself as it's likely a system package

    # Remove aliases file
    step "Removing shell aliases"
    if [[ -f "$HOME/.vibe-palace/uranus_aliases.sh" ]]; then
        rm -f "$HOME/.vibe-palace/uranus_aliases.sh"
        success "Aliases file removed"
    fi

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Uranus uninstalled"
    log ""
    log "NOTE: Mercury (terminal tools) was NOT removed"
    log "      Each planet is independent!"
    log ""
    log "NOTE: Git config settings were preserved"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Uranus health..."

    # Check Git
    if command_exists git; then
        local git_version
        git_version=$(git --version 2>/dev/null || echo "unknown")
        success "Git: $git_version"
    else
        error "Git not found in PATH"
        ((failed++))
    fi

    # Check lazygit
    if command_exists lazygit; then
        success "lazygit installed"
    else
        error "lazygit not found in PATH"
        ((failed++))
    fi

    # Check GitHub CLI
    if command_exists gh; then
        success "GitHub CLI installed"
    else
        error "GitHub CLI not found in PATH"
        ((failed++))
    fi

    # Check git-lfs
    if command_exists git-lfs; then
        success "git-lfs installed"
    else
        warn "git-lfs not found (optional)"
    fi

    # Check jq
    if command_exists jq; then
        success "jq installed"
    else
        error "jq not found in PATH"
        ((failed++))
    fi

    # Check yq
    if command_exists yq; then
        success "yq installed"
    else
        error "yq not found in PATH"
        ((failed++))
    fi

    # Check httpie
    if command_exists http; then
        success "httpie installed"
    else
        error "httpie not found in PATH"
        ((failed++))
    fi

    # Check gum
    if command_exists gum; then
        success "gum installed"
    else
        error "gum not found in PATH"
        ((failed++))
    fi

    # Check just
    if command_exists just; then
        success "just installed"
    else
        warn "just not found (optional)"
    fi

    # Check aliases file
    echo ""
    if [[ -f "$HOME/.vibe-palace/uranus_aliases.sh" ]]; then
        success "Shell aliases file exists"
    else
        warn "Shell aliases file not found"
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

    success "Uranus is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists git && \
        command_exists lazygit && \
        command_exists gh && \
        command_exists jq && \
        command_exists yq && \
        command_exists gum && \
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
