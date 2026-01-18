#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Mercury
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Terminal Foundation - Core terminal experience tools
# Duration: ~5 min
# Dependencies: none
#
# Tools:
#   - Starship: Cross-shell prompt
#   - Zoxide: Smarter cd command
#   - eza: Modern ls replacement
#   - bat: Cat clone with wings
#   - delta: Syntax-highlighting pager for git
#   - fzf: Command-line fuzzy finder
#   - ripgrep: Fast grep alternative
#   - fd: Fast find alternative
#   - tmux: Terminal multiplexer
#   - TPM: Tmux Plugin Manager
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

PLANET_NAME="mercury"
PLANET_VERSION="1.0.0"
PLANET_DESC="Terminal Foundation - Core terminal tools (starship, zoxide, eza, bat, delta, fzf, ripgrep, fd, tmux)"

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
    # Mercury has no dependencies - it's the foundation!
    echo ""
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

# install_starship: Install Starship prompt
install_starship() {
    step "Installing Starship prompt"

    if command_exists starship; then
        log "starship already installed"
        return 0
    fi

    brew install starship
    success "starship installed"
}

# configure_starship: Create Starship config
configure_starship() {
    step "Configuring Starship prompt"

    local config_dir="$HOME/.config"
    local config_file="$config_dir/starship.toml"

    if [[ -f "$config_file" ]]; then
        log "starship.toml already exists, backing up"
        cp "$config_file" "${config_file}.backup_$(date +%s)"
    fi

    ensure_dir "$config_dir"

    cat > "$config_file" << 'STARSHIP'
format = """
[╭─](bold blue)$username$hostname$directory$git_branch$git_status$nodejs$python$rust$golang
[╰─](bold blue)$character"""

[username]
style_user = "bold cyan"
format = "[$user]($style)"
show_always = true

[hostname]
ssh_only = false
format = "[@$hostname](bold magenta) "

[directory]
style = "bold green"
truncation_length = 5
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "

[git_branch]
symbol = " "
style = "bold purple"
format = "[$symbol$branch]($style) "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold red"

[nodejs]
symbol = " "
format = "[$symbol($version)]($style) "

[python]
symbol = " "
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
format = "[$symbol($version)]($style) "

[golang]
symbol = " "
format = "[$symbol($version)]($style) "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
STARSHIP

    success "Starship configured"
}

# install_zoxide: Install Zoxide
install_zoxide() {
    step "Installing Zoxide"

    if command_exists zoxide; then
        log "zoxide already installed"
        return 0
    fi

    brew install zoxide
    success "zoxide installed"
}

# install_eza: Install eza (modern ls)
install_eza() {
    step "Installing eza (modern ls)"

    if command_exists eza; then
        log "eza already installed"
        return 0
    fi

    brew install eza
    success "eza installed"
}

# install_bat: Install bat (cat clone)
install_bat() {
    step "Installing bat (cat with wings)"

    if command_exists bat; then
        log "bat already installed"
        return 0
    fi

    brew install bat
    success "bat installed"
}

# install_delta: Install delta (git pager)
install_delta() {
    step "Installing delta (git diff pager)"

    if command_exists delta; then
        log "delta already installed"
        return 0
    fi

    brew install git-delta
    success "delta installed"
}

# install_fzf: Install fzf (fuzzy finder)
install_fzf() {
    step "Installing fzf (fuzzy finder)"

    if command_exists fzf; then
        log "fzf already installed"
        return 0
    fi

    brew install fzf
    success "fzf installed"
}

# install_ripgrep: Install ripgrep
install_ripgrep() {
    step "Installing ripgrep"

    if command_exists rg; then
        log "ripgrep already installed"
        return 0
    fi

    brew install ripgrep
    success "ripgrep installed"
}

# install_fd: Install fd (find alternative)
install_fd() {
    step "Installing fd (find alternative)"

    if command_exists fd; then
        log "fd already installed"
        return 0
    fi

    brew install fd
    success "fd installed"
}

# install_tmux: Install tmux terminal multiplexer
install_tmux() {
    step "Installing tmux terminal multiplexer"

    if command_exists tmux; then
        log "tmux already installed"
        return 0
    fi

    brew install tmux
    success "tmux installed"
}

# install_tpm: Install Tmux Plugin Manager
install_tpm() {
    step "Installing TPM (Tmux Plugin Manager)"

    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log "TPM already installed"
        return 0
    fi

    ensure_dir "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    success "TPM installed"
}

# configure_tmux: Create tmux config
configure_tmux() {
    step "Configuring tmux"

    local config_file="$HOME/.tmux.conf"

    if [[ -f "$config_file" ]]; then
        log "tmux.conf already exists, backing up"
        cp "$config_file" "${config_file}.backup_$(date +%s)"
    fi

    cat > "$config_file" << 'TMUX'
# ═══════════════════════════════════════════════════════════════════════════════
# VIBE PALACE TMUX CONFIG
# ═══════════════════════════════════════════════════════════════════════════════

set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Mouse
set -g mouse on

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows
set -g renumber-windows on

# History
set -g history-limit 50000

# Faster escape
set -sg escape-time 0

# Vi mode
setw -g mode-keys vi

# Split panes
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Navigate panes with vim keys
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# ═══════════════════════════════════════════════════════════════════════════════
# THEME - CATPPUCCIN VIBES
# ═══════════════════════════════════════════════════════════════════════════════

set -g status-position top
set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
set -g status-left-length 100
set -g status-right-length 100
set -g status-left '#[fg=#1e1e2e,bg=#89b4fa,bold] #S #[fg=#89b4fa,bg=#1e1e2e]'
set -g status-right '#[fg=#45475a]#[fg=#cdd6f4,bg=#45475a] %H:%M #[fg=#89b4fa]#[fg=#1e1e2e,bg=#89b4fa,bold] #h '
setw -g window-status-format '#[fg=#6c7086] #I:#W '
setw -g window-status-current-format '#[fg=#f5c2e7,bold] #I:#W '

# ═══════════════════════════════════════════════════════════════════════════════
# PLUGINS
# ═══════════════════════════════════════════════════════════════════════════════

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

set -g @continuum-restore 'on'
set -g @resurrect-capture-pane-contents 'on'

run '~/.tmux/plugins/tpm/tpm'
TMUX

    success "tmux configured"
}

# planet_install: Main installation logic
planet_install() {
    banner "🪐 MERCURY: Terminal Foundation"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Mercury already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install terminal tools
    install_starship
    configure_starship

    install_zoxide
    install_eza
    install_bat
    install_delta
    install_fzf
    install_ripgrep
    install_fd

    # Install tmux and TPM
    install_tmux
    install_tpm
    configure_tmux

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Mercury installation complete!"
    log ""
    log "Next steps:"
    log "  1. Add Starship to your shell config (~/.bashrc or ~/.zshrc):"
    log "     eval \"\$(starship init bash)\"  # or zsh/fish"
    log "  2. Add Zoxide to your shell config:"
    log "     eval \"\$(zoxide init bash)\"  # or zsh/fish"
    log "  3. Install tmux plugins:"
    log "     ~/.tmux/plugins/tpm/bin/install_plugins"
    log "  4. Start a new shell or run: source ~/.bashrc"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🪐 Uninstalling Mercury"

    # Check if installed
    if ! planet_is_installed; then
        warn "Mercury not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Mercury tools"

    # Remove via Homebrew
    local tools=("starship" "zoxide" "eza" "bat" "git-delta" "fzf" "ripgrep" "fd" "tmux")

    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            log "Uninstalling $tool..."
            brew uninstall "$tool" 2>/dev/null || true
            success "$tool removed"
        fi
    done

    # Remove TPM
    step "Removing TPM"
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        rm -rf "$HOME/.tmux/plugins/tpm"
        success "TPM removed"
    fi

    # Remove configs (with backup warning)
    step "Backing up configs"
    local configs=("$HOME/.config/starship.toml" "$HOME/.tmux.conf")
    local backup_dir="$VIBE_DIR/mercury_backup_$(date +%s)"

    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            ensure_dir "$backup_dir"
            cp "$config" "$backup_dir/"
            log "Backed up: $config -> $backup_dir/"
            rm -f "$config"
            success "Removed: $config"
        fi
    done

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Mercury uninstalled"
    log "Configs backed up to: $backup_dir"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Mercury health..."

    # Check binaries
    local binaries=("starship" "zoxide" "eza" "bat" "delta" "fzf" "rg" "fd" "tmux")

    for binary in "${binaries[@]}"; do
        if command_exists "$binary"; then
            success "$binary installed"
        else
            error "$binary not found in PATH"
            ((failed++))
        fi
    done

    # Check TPM
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        success "TPM installed"
    else
        error "TPM directory not found"
        ((failed++))
    fi

    # Check configs
    if [[ -f "$HOME/.config/starship.toml" ]]; then
        success "starship.toml exists"
    else
        error "starship.toml missing"
        ((failed++))
    fi

    if [[ -f "$HOME/.tmux.conf" ]]; then
        success "tmux.conf exists"
    else
        error "tmux.conf missing"
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
    echo ""
    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issue(s)"
        return 1
    fi

    success "Mercury is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists starship && \
        command_exists eza && \
        command_exists bat && \
        command_exists tmux && \
        [[ -f "$HOME/.config/starship.toml" ]] && \
        [[ -f "$HOME/.tmux.conf" ]] && \
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
