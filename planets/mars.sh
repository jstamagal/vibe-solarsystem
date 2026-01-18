#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Mars
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Programming Languages - Language runtimes & package managers
# Duration: ~15 min
# Dependencies: mercury
#
# Tools:
#   - fnm: Fast Node Manager (Node.js)
#   - pyenv: Python version manager
#   - rustup: Rust toolchain installer
#   - Go: Go programming language
#   - Java: OpenJDK (optional)
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

PLANET_NAME="mars"
PLANET_VERSION="1.0.0"
PLANET_DESC="Programming Languages - fnm (Node.js), pyenv (Python), rustup (Rust), Go"

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
  "duration": "15 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # Mars depends on Mercury for terminal tools
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

# ═══════════════════════════════════════════════════════════════════════════════
# NODE.JS - FNM (Fast Node Manager)
# ═══════════════════════════════════════════════════════════════════════════════

# install_fnm: Install fnm (Fast Node Manager)
install_fnm() {
    step "Installing fnm (Fast Node Manager)"

    if command_exists fnm; then
        log "fnm already installed"
        return 0
    fi

    brew install fnm
    success "fnm installed"
}

# configure_fnm: Configure fnm and install Node.js LTS
configure_fnm() {
    step "Configuring fnm and installing Node.js LTS"

    local shellrc_file="$HOME/.vibe-palace/mars_fnm.sh"

    # Create fnm shell integration
    cat > "$shellrc_file" << 'FNM'
# Vibe Palace - Mars: fnm (Node.js)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"
FNM

    # Load fnm into current shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    if command_exists fnm && eval "$(fnm env --use-on-cd)"; then
        log "fnm environment loaded"

        # Install Node.js LTS
        if fnm list | grep -q "lts-latest"; then
            log "Node.js LTS already installed"
        else
            log "Installing Node.js LTS..."
            fnm install --lts
            fnm alias lts-latest lts
            fnm use lts-latest
            success "Node.js $(node --version) installed"
        fi

        # Install global npm packages
        step "Installing global npm packages"
        local npm_packages=(
            "typescript"
            "ts-node"
            "tsx"
            "@types/node"
            "pnpm"
            "yarn"
            "npm-check-updates"
            "depcheck"
            "prettier"
            "eslint"
            "turbo"
            "vercel"
            "wrangler"
            "@cloudflare/workers-types"
            "create-next-app"
            "create-t3-app"
            "prisma"
            "drizzle-kit"
        )

        for pkg in "${npm_packages[@]}"; do
            if npm list -g "$pkg" &>/dev/null; then
                log "$pkg already installed"
            else
                log "Installing $pkg..."
                npm install -g "$pkg" 2>/dev/null || true
            fi
        done

        success "Global npm packages installed"
    fi

    success "fnm configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PYTHON - PYENV
# ═══════════════════════════════════════════════════════════════════════════════

# install_pyenv: Install pyenv and pyenv-virtualenv
install_pyenv() {
    step "Installing pyenv and pyenv-virtualenv"

    if command_exists pyenv; then
        log "pyenv already installed"
        return 0
    fi

    brew install pyenv pyenv-virtualenv
    success "pyenv installed"
}

# configure_pyenv: Configure pyenv and install Python 3.12
configure_pyenv() {
    step "Configuring pyenv and installing Python 3.12"

    local shellrc_file="$HOME/.vibe-palace/mars_pyenv.sh"

    # Create pyenv shell integration
    cat > "$shellrc_file" << 'PYENV'
# Vibe Palace - Mars: pyenv (Python)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
PYENV

    # Load pyenv into current shell
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command_exists pyenv && eval "$(pyenv init -)"; then
        log "pyenv environment loaded"

        # Install Python 3.12
        if pyenv versions | grep -q "3.12"; then
            log "Python 3.12 already installed"
        else
            log "Installing Python 3.12..."
            pyenv install 3.12 -s
            pyenv global 3.12
            success "Python $(python --version) installed"
        fi

        # Install Python tools
        step "Installing Python tools"
        local pip_tools=(
            "pip"
            "pipx"
            "poetry"
            "black"
            "ruff"
            "mypy"
            "pytest"
            "ipython"
            "rich"
            "httpx"
            "aiohttp"
        )

        # Upgrade pip first
        log "Upgrading pip..."
        pip install --upgrade pip --quiet

        # Install tools
        for tool in "${pip_tools[@]}"; do
            if pip show "$tool" &>/dev/null; then
                log "$tool already installed"
            else
                log "Installing $tool..."
                pip install "$tool" --quiet 2>/dev/null || true
            fi
        done

        # Configure pipx
        if command_exists pipx; then
            pipx ensurepath &>/dev/null || true
        fi

        success "Python tools installed"
    fi

    success "pyenv configured"
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUST - RUSTUP
# ═══════════════════════════════════════════════════════════════════════════════

# install_rustup: Install Rust via rustup
install_rustup() {
    step "Installing Rust via rustup"

    if command_exists rustc; then
        log "Rust already installed"
        local version
        version=$(rustc --version)
        log "Current version: $version"
        return 0
    fi

    # Download and run rustup installer
    log "Downloading rustup installer..."
    if command_exists curl; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    else
        error "curl is required to install Rust"
        return 1
    fi

    success "Rust installed"
}

# configure_rustup: Install Rust components and cargo tools
configure_rustup() {
    step "Configuring Rust toolchain"

    local shellrc_file="$HOME/.vibe-palace/mars_rust.sh"

    # Create Rust shell integration
    cat > "$shellrc_file" << 'RUST'
# Vibe Palace - Mars: Rust
. "$HOME/.cargo/env"
RUST

    # Load Rust environment
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
        log "Rust environment loaded"

        # Install Rust components
        if command_exists rustup; then
            log "Installing Rust components..."
            rustup component add rust-analyzer clippy rustfmt 2>/dev/null || true
            success "Rust components installed"
        fi

        # Install cargo tools
        if command_exists cargo; then
            step "Installing cargo tools"
            local cargo_tools=(
                "cargo-watch"
                "cargo-edit"
                "cargo-expand"
                "cargo-udeps"
                "cargo-nextest"
                "sccache"
            )

            for tool in "${cargo_tools[@]}"; do
                if cargo install --list | grep -q "^$tool"; then
                    log "$tool already installed"
                else
                    log "Installing $tool..."
                    cargo install "$tool" --quiet 2>/dev/null || true
                fi
            done

            success "Cargo tools installed"
        fi

        success "Rust $(rustc --version) configured"
    else
        error "Rust environment not found"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# GO - GOLANG
# ═══════════════════════════════════════════════════════════════════════════════

# install_golang: Install Go programming language
install_golang() {
    step "Installing Go programming language"

    if command_exists go; then
        log "Go already installed"
        local version
        version=$(go version)
        log "Current version: $version"
        return 0
    fi

    brew install go
    success "Go installed"
}

# configure_golang: Configure Go environment
configure_golang() {
    step "Configuring Go environment"

    local shellrc_file="$HOME/.vibe-palace/mars_golang.sh"

    # Create Go shell integration
    cat > "$shellrc_file" << 'GOLANG'
# Vibe Palace - Mars: Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
GOLANG

    # Load Go environment
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"

    if command_exists go; then
        log "Go environment loaded"
        success "Go $(go version | awk '{print $3}') configured"
    else
        warn "Go not found in PATH"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# JAVA - OPTIONAL
# ═══════════════════════════════════════════════════════════════════════════════

# install_java: Install OpenJDK (optional)
install_java() {
    step "Installing OpenJDK (optional)"

    if command_exists java; then
        log "Java already installed"
        local version
        version=$(java -version 2>&1 | head -n1)
        log "Current version: $version"
        return 0
    fi

    # Ask user if they want Java
    if ask_yes_no "Install Java (OpenJDK)?"; then
        brew install openjdk@17
        success "Java installed"
    else
        log "Skipping Java installation"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_install: Main installation logic
planet_install() {
    banner "🔭 MARS: Programming Languages"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Mars already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install Node.js (fnm)
    install_fnm
    configure_fnm

    # Install Python (pyenv)
    install_pyenv
    configure_pyenv

    # Install Rust (rustup)
    install_rustup
    configure_rustup

    # Install Go
    install_golang
    configure_golang

    # Install Java (optional)
    install_java

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Mars installation complete!"
    log ""
    log "Next steps:"
    log "  1. Source the language environment scripts in your shell config:"
    log "     # Add to ~/.bashrc or ~/.zshrc:"
    log "     source ~/.vibe-palace/mars_fnm.sh"
    log "     source ~/.vibe-palace/mars_pyenv.sh"
    log "     source ~/.vibe-palace/mars_rust.sh"
    log "     source ~/.vibe-palace/mars_golang.sh"
    log ""
    log "  2. Start a new shell or run: source ~/.bashrc"
    log "  3. Verify installations:"
    log "     node --version    # Node.js"
    log "     python --version  # Python"
    log "     rustc --version   # Rust"
    log "     go version        # Go"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🔭 Uninstalling Mars"

    # Check if installed
    if ! planet_is_installed; then
        warn "Mars not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Mars tools"

    # Remove language runtimes (preserve user code)
    warn "Language runtimes will be removed, but user projects will be preserved"

    # Remove fnm and Node.js
    if command_exists fnm; then
        log "Removing fnm and Node.js installations..."
        # Remove fnm via Homebrew
        brew uninstall fnm 2>/dev/null || true
        # Remove fnm directory
        rm -rf "$HOME/.local/share/fnm"
        success "fnm removed"
    fi

    # Remove pyenv and Python
    if command_exists pyenv; then
        log "Removing pyenv and Python installations..."
        # Remove pyenv via Homebrew
        brew uninstall pyenv pyenv-virtualenv 2>/dev/null || true
        # Remove pyenv directory
        rm -rf "$HOME/.pyenv"
        success "pyenv removed"
    fi

    # Remove Rust
    if command_exists rustup; then
        log "Removing Rust installation..."
        # Use rustup self-uninstall
        rustup self uninstall -y 2>/dev/null || true
        # Remove cargo directory
        rm -rf "$HOME/.cargo"
        success "Rust removed"
    fi

    # Remove Go
    if command_exists go; then
        log "Removing Go installation..."
        # Remove Go via Homebrew
        brew uninstall go 2>/dev/null || true
        # Remove GOPATH
        rm -rf "$HOME/go"
        success "Go removed"
    fi

    # Remove Java (if installed)
    if brew list openjdk@17 &>/dev/null; then
        log "Removing Java installation..."
        brew uninstall openjdk@17 2>/dev/null || true
        success "Java removed"
    fi

    # Remove shell integration files
    step "Removing shell integration files"
    rm -f "$HOME/.vibe-palace/mars_fnm.sh"
    rm -f "$HOME/.vibe-palace/mars_pyenv.sh"
    rm -f "$HOME/.vibe-palace/mars_rust.sh"
    rm -f "$HOME/.vibe-palace/mars_golang.sh"
    success "Shell integration files removed"

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Mars uninstalled"
    log ""
    log "NOTE: Mercury (terminal tools) was NOT removed"
    log "      Each planet is independent!"
    log ""
    log "NOTE: User projects in ~/dev, ~/projects, etc. were preserved"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Mars health..."

    # Check fnm and Node.js
    if command_exists fnm; then
        success "fnm installed"

        # Try to get Node.js version
        if command_exists node; then
            local node_version
            node_version=$(node --version 2>/dev/null || echo "unknown")
            success "Node.js: $node_version"
        else
            warn "Node.js not found (may need to source mars_fnm.sh)"
        fi

        if command_exists npm; then
            local npm_version
            npm_version=$(npm --version 2>/dev/null || echo "unknown")
            success "npm: $npm_version"
        else
            warn "npm not found"
        fi
    else
        error "fnm not found in PATH"
        ((failed++))
    fi

    # Check pyenv and Python
    if command_exists pyenv; then
        success "pyenv installed"

        # Try to get Python version
        if command_exists python; then
            local python_version
            python_version=$(python --version 2>&1 || echo "unknown")
            success "Python: $python_version"
        else
            warn "Python not found (may need to source mars_pyenv.sh)"
        fi

        if command_exists pip; then
            success "pip installed"
        else
            warn "pip not found"
        fi
    else
        error "pyenv not found in PATH"
        ((failed++))
    fi

    # Check Rust
    if command_exists rustc; then
        local rust_version
        rust_version=$(rustc --version 2>/dev/null || echo "unknown")
        success "Rust: $rust_version"

        if command_exists cargo; then
            success "cargo installed"
        else
            warn "cargo not found"
        fi
    else
        error "Rust not found in PATH"
        ((failed++))
    fi

    # Check Go
    if command_exists go; then
        local go_version
        go_version=$(go version 2>/dev/null || echo "unknown")
        success "Go: $go_version"
    else
        error "Go not found in PATH"
        ((failed++))
    fi

    # Check shell integration files
    echo ""
    log "Checking shell integration files..."

    local shell_files=(
        "mars_fnm.sh"
        "mars_pyenv.sh"
        "mars_rust.sh"
        "mars_golang.sh"
    )

    for file in "${shell_files[@]}"; do
        if [[ -f "$HOME/.vibe-palace/$file" ]]; then
            success "$file exists"
        else
            warn "$file not found"
        fi
    done

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
        echo ""
        echo "TIP: If tools are installed but not found, try sourcing the shell integration files:"
        echo "  source ~/.vibe-palace/mars_fnm.sh"
        echo "  source ~/.vibe-palace/mars_pyenv.sh"
        echo "  source ~/.vibe-palace/mars_rust.sh"
        echo "  source ~/.vibe-palace/mars_golang.sh"
        return 1
    fi

    success "Mars is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists fnm && \
        command_exists pyenv && \
        command_exists rustc && \
        command_exists go && \
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
