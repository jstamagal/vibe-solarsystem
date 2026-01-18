#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                                                                              ║
# ║   ██╗   ██╗██╗██████╗ ███████╗    ██████╗  █████╗ ██╗      █████╗  ██████╗███████╗║
# ║   ██║   ██║██║██╔══██╗██╔════╝    ██╔══██╗██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝║
# ║   ██║   ██║██║██████╔╝█████╗      ██████╔╝███████║██║     ███████║██║     █████╗  ║
# ║   ╚██╗ ██╔╝██║██╔══██╗██╔══╝      ██╔═══╝ ██╔══██║██║     ██╔══██║██║     ██╔══╝  ║
# ║    ╚████╔╝ ██║██████╔╝███████╗    ██║     ██║  ██║███████╗██║  ██║╚██████╗███████╗║
# ║     ╚═══╝  ╚═╝╚═════╝ ╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝║
# ║                                                                              ║
# ║                    THE ULTIMATE 1000000X VIBE CODING SETUP                   ║
# ║                         CLI/TUI ONLY - NO GUI PEASANTS                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VIBE_DIR="$HOME/.vibe-palace"
LOG_FILE="$VIBE_DIR/install.log"

mkdir -p "$VIBE_DIR"

log() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

banner() {
    echo -e "${MAGENTA}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 0: SYSTEM PREP - GET THIS UBUNTU BOX READY FOR GLORY
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 0: SYSTEM PREPARATION"

log "Updating system packages..."
sudo apt update && sudo apt upgrade -y

log "Installing essential build tools and dependencies..."
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    zip \
    tar \
    gzip \
    file \
    procps \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    pkg-config \
    autoconf \
    automake \
    libtool \
    cmake \
    ninja-build \
    gettext \
    libevent-dev \
    ncurses-dev \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    fd-find \
    bat \
    jq \
    htop \
    tree \
    fzf \
    silversearcher-ag \
    universal-ctags \
    xclip \
    xsel

success "System packages installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: HOMEBREW - BECAUSE UBUNTU REPOS ARE FOR SQUARES
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 1: HOMEBREW INSTALLATION"

if ! command -v brew &> /dev/null; then
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to shell profiles
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
    
    if [[ -f "$HOME/.zshrc" ]]; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
    fi
    
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    success "Homebrew installed"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    success "Homebrew already installed"
fi

log "Updating Homebrew..."
brew update

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: TERMINAL BLING - BECAUSE AESTHETICS MATTER
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 2: TERMINAL BLING"

log "Installing terminal tools via Homebrew..."
brew install \
    starship \
    zoxide \
    eza \
    bat \
    delta \
    lazygit \
    lazydocker \
    bottom \
    dust \
    duf \
    procs \
    sd \
    choose \
    hyperfine \
    tokei \
    bandwhich \
    grex \
    tealdeer \
    glow \
    navi \
    broot \
    yazi

success "Terminal bling installed"

# Starship prompt config
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'STARSHIP'
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

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3: NEOVIM 0.11+ FROM HOMEBREW - THE REAL SHIT
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 3: NEOVIM 0.11+"

log "Installing Neovim from Homebrew (latest version)..."
brew install neovim

NVIM_VERSION=$(nvim --version | head -n1)
success "Neovim installed: $NVIM_VERSION"

# LazyVim setup - the ultimate Neovim config
log "Setting up LazyVim..."
if [[ -d "$HOME/.config/nvim" ]]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
if [[ -d "$HOME/.local/share/nvim" ]]; then
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak.$(date +%s)"
fi

git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"

success "LazyVim installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: TMUX - TERMINAL MULTIPLEXER FOR CHADS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 4: TMUX SETUP"

log "Installing tmux from Homebrew..."
brew install tmux

# TPM (Tmux Plugin Manager)
log "Installing TPM..."
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true

cat > "$HOME/.tmux.conf" << 'TMUX'
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

success "Tmux configured"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5: NODE.JS - T3 STACK FOUNDATION
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 5: NODE.JS ECOSYSTEM"

log "Installing fnm (Fast Node Manager)..."
brew install fnm

# Add fnm to shell
cat >> "$HOME/.bashrc" << 'FNM'

# fnm
eval "$(fnm env --use-on-cd)"
FNM

if [[ -f "$HOME/.zshrc" ]]; then
    cat >> "$HOME/.zshrc" << 'FNM'

# fnm
eval "$(fnm env --use-on-cd)"
FNM
fi

export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

log "Installing Node.js LTS..."
fnm install --lts
fnm use lts-latest
fnm default lts-latest

success "Node.js $(node --version) installed"

log "Installing global npm packages..."
npm install -g \
    typescript \
    ts-node \
    tsx \
    @types/node \
    pnpm \
    yarn \
    npm-check-updates \
    depcheck \
    prettier \
    eslint \
    turbo \
    vercel \
    wrangler \
    @cloudflare/workers-types \
    create-next-app \
    create-t3-app \
    prisma \
    drizzle-kit

success "Global npm packages installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 6: PYTHON - BECAUSE AI NEEDS IT
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 6: PYTHON ECOSYSTEM"

log "Installing pyenv..."
brew install pyenv pyenv-virtualenv

cat >> "$HOME/.bashrc" << 'PYENV'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
PYENV

if [[ -f "$HOME/.zshrc" ]]; then
    cat >> "$HOME/.zshrc" << 'PYENV'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
PYENV
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

log "Installing Python 3.12..."
pyenv install 3.12 -s
pyenv global 3.12

success "Python $(python --version) installed"

log "Installing Python tools..."
pip install --upgrade pip
pip install \
    pipx \
    poetry \
    black \
    ruff \
    mypy \
    pytest \
    ipython \
    rich \
    httpx \
    aiohttp

pipx ensurepath

success "Python tools installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 7: RUST - BLAZINGLY FAST
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 7: RUST ECOSYSTEM"

log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

cat >> "$HOME/.bashrc" << 'RUST'

# Rust
. "$HOME/.cargo/env"
RUST

if [[ -f "$HOME/.zshrc" ]]; then
    cat >> "$HOME/.zshrc" << 'RUST'

# Rust
. "$HOME/.cargo/env"
RUST
fi

source "$HOME/.cargo/env"

log "Installing Rust components..."
rustup component add rust-analyzer clippy rustfmt

log "Installing cargo tools..."
cargo install \
    cargo-watch \
    cargo-edit \
    cargo-expand \
    cargo-udeps \
    cargo-nextest \
    sccache

success "Rust $(rustc --version) installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 8: GO - FOR THE TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 8: GO ECOSYSTEM"

log "Installing Go..."
brew install go

cat >> "$HOME/.bashrc" << 'GOLANG'

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
GOLANG

if [[ -f "$HOME/.zshrc" ]]; then
    cat >> "$HOME/.zshrc" << 'GOLANG'

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
GOLANG
fi

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

success "Go $(go version) installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 9: CLAUDE CODE - THE MAIN EVENT
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 9: CLAUDE CODE"

log "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

success "Claude Code installed"

# Clone Claude Code repo for the good stuff
log "Cloning Claude Code repository for MCP servers and extensions..."
mkdir -p "$VIBE_DIR/repos"
git clone https://github.com/anthropics/claude-code.git "$VIBE_DIR/repos/claude-code" 2>/dev/null || {
    cd "$VIBE_DIR/repos/claude-code" && git pull
}

# Check for MCP servers in the repo
if [[ -d "$VIBE_DIR/repos/claude-code/mcp-servers" ]]; then
    log "Found MCP servers in claude-code repo!"
    ls -la "$VIBE_DIR/repos/claude-code/mcp-servers"
fi

success "Claude Code repo cloned to $VIBE_DIR/repos/claude-code"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 10: MCP SERVERS - THE EXTENSIONS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 10: MCP SERVERS"

log "Installing official MCP servers..."

# Clone MCP servers repo
git clone https://github.com/modelcontextprotocol/servers.git "$VIBE_DIR/repos/mcp-servers" 2>/dev/null || {
    cd "$VIBE_DIR/repos/mcp-servers" && git pull
}

# Install commonly used MCP servers
npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-postgres \
    @modelcontextprotocol/server-sqlite \
    @modelcontextprotocol/server-memory \
    @modelcontextprotocol/server-brave-search \
    @modelcontextprotocol/server-puppeteer \
    @modelcontextprotocol/server-fetch

success "MCP servers installed"

# Create MCP config directory
mkdir -p "$HOME/.config/claude-code"

cat > "$HOME/.config/claude-code/mcp-servers.json" << 'MCP'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
MCP

success "MCP config created at ~/.config/claude-code/mcp-servers.json"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 11: OPENAI CODEX CLI
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 11: OPENAI CODEX CLI"

log "Installing OpenAI Codex CLI..."
npm install -g @openai/codex

success "OpenAI Codex CLI installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 12: GOOGLE GEMINI CLI
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 12: GOOGLE GEMINI CLI"

log "Installing Gemini CLI..."
npm install -g @anthropic-ai/claude-code  # Placeholder - update when official CLI available

# Install aichat as alternative multi-model CLI
brew install aichat

success "AI CLI tools installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 13: DOCKER - CONTAINERS FOR DAYS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 13: DOCKER"

if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    success "Docker installed (logout/login for group changes)"
else
    success "Docker already installed"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 14: DATABASE TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 14: DATABASE TOOLS"

log "Installing database CLIs..."
brew install \
    postgresql@16 \
    mysql-client \
    redis \
    mongosh

# pgcli and mycli for better database experience
pip install pgcli mycli litecli iredis

success "Database tools installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 15: GIT CONFIG - PROFESSIONAL SETUP
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 15: GIT CONFIG"

log "Installing git tools..."
brew install gh git-lfs

# Delta as git pager
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

# Useful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

git lfs install

success "Git configured"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 16: ZSH - OPTIONAL BUT RECOMMENDED
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 16: ZSH SETUP"

log "Installing Zsh..."
sudo apt install -y zsh

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null || true

cat > "$HOME/.zshrc" << 'ZSHRC'
# ═══════════════════════════════════════════════════════════════════════════════
# VIBE PALACE ZSH CONFIG
# ═══════════════════════════════════════════════════════════════════════════════

export ZSH="$HOME/.oh-my-zsh"

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

source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# fnm
eval "$(fnm env --use-on-cd)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Rust
. "$HOME/.cargo/env"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Atuin (shell history)
eval "$(atuin init zsh)"

# ═══════════════════════════════════════════════════════════════════════════════
# ALIASES - VIBE CODING SHORTCUTS
# ═══════════════════════════════════════════════════════════════════════════════

# Modern replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'
alias top='btm'
alias du='dust'
alias df='duf'
alias ps='procs'

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

# Docker
alias d='docker'
alias dc='docker compose'
alias ld='lazydocker'

# Development
alias v='nvim'
alias vim='nvim'
alias t='tmux'
alias ta='tmux attach'

# AI Coding
alias cc='claude'
alias claude='claude'

# T3 Stack
alias t3='pnpm create t3-app@latest'
alias next='pnpm create next-app@latest'

# Package managers
alias p='pnpm'
alias pi='pnpm install'
alias pd='pnpm dev'
alias pb='pnpm build'

# Directories
alias dev='cd ~/dev'
alias proj='cd ~/projects'
alias dot='cd ~/.config'

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

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 17: ADDITIONAL VIBE TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 17: ADDITIONAL VIBE TOOLS"

log "Installing additional tools..."

# Gum - for beautiful shell scripts
brew install gum

# Charm tools
brew install charm

# Task runner
brew install just

# HTTP client
brew install httpie curlie xh

# JSON tools
brew install jless fx

# Markdown
brew install glow

# File manager
brew install lf

# Process viewer
brew install bottom

# Network tools
brew install bandwhich trippy

success "Additional tools installed"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 18: CREATE PROJECT DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 18: PROJECT STRUCTURE"

log "Creating project directories..."

mkdir -p "$HOME/projects"
mkdir -p "$HOME/dev"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config"

success "Project directories created"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 19: FINAL SHELL CONFIG
# ═══════════════════════════════════════════════════════════════════════════════

banner "PHASE 19: FINAL SHELL CONFIG"

# Update bashrc with all the goodies
cat >> "$HOME/.bashrc" << 'BASHRC'

# ═══════════════════════════════════════════════════════════════════════════════
# VIBE PALACE BASH CONFIG
# ═══════════════════════════════════════════════════════════════════════════════

# Starship prompt
eval "$(starship init bash)"

# Zoxide
eval "$(zoxide init bash)"

# Atuin
eval "$(atuin init bash)"

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'
alias top='btm'
alias v='nvim'
alias vim='nvim'
alias t='tmux'
alias lg='lazygit'
alias ld='lazydocker'
alias cc='claude'
alias g='git'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias p='pnpm'
alias pi='pnpm install'
alias pd='pnpm dev'

# PATH
export PATH="$HOME/.local/bin:$PATH"
BASHRC

success "Shell config updated"

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION COMPLETE
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${MAGENTA}"
cat << 'COMPLETE'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ██╗   ██╗██╗██████╗ ███████╗    ██████╗  █████╗ ██╗      █████╗  ██████╗███████╗║
║   ██║   ██║██║██╔══██╗██╔════╝    ██╔══██╗██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝║
║   ██║   ██║██║██████╔╝█████╗      ██████╔╝███████║██║     ███████║██║     █████╗  ║
║   ╚██╗ ██╔╝██║██╔══██╗██╔══╝      ██╔═══╝ ██╔══██║██║     ██╔══██║██║     ██╔══╝  ║
║    ╚████╔╝ ██║██████╔╝███████╗    ██║     ██║  ██║███████╗██║  ██║╚██████╗███████╗║
║     ╚═══╝  ╚═╝╚═════╝ ╚══════╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝║
║                                                                              ║
║                    ✅ INSTALLATION COMPLETE ✅                                ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
COMPLETE
echo -e "${NC}"

echo -e "${GREEN}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                         WHAT'S INSTALLED:"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${CYAN}📦 PACKAGE MANAGERS:${NC}"
echo "   • Homebrew (latest packages)"
echo "   • fnm (Node.js)"
echo "   • pyenv (Python)"
echo "   • rustup (Rust)"
echo "   • pnpm, yarn, npm"
echo ""

echo -e "${CYAN}🤖 AI CODING TOOLS:${NC}"
echo "   • Claude Code (claude)"
echo "   • OpenAI Codex CLI"
echo "   • aichat (multi-model)"
echo "   • MCP Servers (filesystem, github, memory, fetch)"
echo ""

echo -e "${CYAN}📝 EDITORS & TERMINAL:${NC}"
echo "   • Neovim 0.11+ with LazyVim"
echo "   • tmux with TPM"
echo "   • Starship prompt"
echo "   • Zsh with Oh My Zsh"
echo ""

echo -e "${CYAN}🛠️ DEV TOOLS:${NC}"
echo "   • lazygit, lazydocker"
echo "   • fzf, ripgrep, fd"
echo "   • eza, bat, delta"
echo "   • yazi (file manager)"
echo "   • bottom, dust, duf"
echo ""

echo -e "${CYAN}🗄️ DATABASES:${NC}"
echo "   • PostgreSQL client"
echo "   • MySQL client"
echo "   • Redis"
echo "   • pgcli, mycli, litecli"
echo ""

echo -e "${CYAN}🌐 WEB DEV (T3 READY):${NC}"
echo "   • Node.js LTS"
echo "   • TypeScript"
echo "   • pnpm create t3-app"
echo "   • Prisma, Drizzle"
echo "   • Vercel CLI"
echo ""

echo -e "${YELLOW}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                         NEXT STEPS:"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${WHITE}1. ${CYAN}Restart your shell or run:${NC}"
echo "   source ~/.bashrc   # or source ~/.zshrc"
echo ""

echo -e "${WHITE}2. ${CYAN}Set up API keys:${NC}"
echo "   export ANTHROPIC_API_KEY='your-key'"
echo "   export OPENAI_API_KEY='your-key'"
echo "   export GITHUB_TOKEN='your-token'"
echo ""

echo -e "${WHITE}3. ${CYAN}Start Claude Code:${NC}"
echo "   claude"
echo ""

echo -e "${WHITE}4. ${CYAN}Create a T3 project:${NC}"
echo "   pnpm create t3-app@latest my-app"
echo ""

echo -e "${WHITE}5. ${CYAN}Install tmux plugins:${NC}"
echo "   tmux"
echo "   Press: Ctrl+a then I (capital i)"
echo ""

echo -e "${WHITE}6. ${CYAN}Open Neovim to install plugins:${NC}"
echo "   nvim"
echo ""

echo -e "${WHITE}7. ${CYAN}Check Claude Code repo for extras:${NC}"
echo "   ls $VIBE_DIR/repos/claude-code"
echo ""

echo -e "${WHITE}8. ${CYAN}Configure MCP servers:${NC}"
echo "   nvim ~/.config/claude-code/mcp-servers.json"
echo ""

echo -e "${GREEN}${BOLD}"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                    🚀 YOU ARE NOW A 1000000X DEVELOPER 🚀"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"

