#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Saturn
# ═══════════════════════════════════════════════════════════════════════════════
# Description: AI Development - AI coding assistants and tools
# Duration: ~5 min
# Dependencies: mars
#
# Tools:
#   - Claude Code CLI
#   - MCP Servers (filesystem, github, memory, fetch, etc.)
#   - aichat (multi-model CLI)
#   - AI helper scripts
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

PLANET_NAME="saturn"
PLANET_VERSION="1.0.0"
PLANET_DESC="AI Development - Claude Code, MCP Servers, aichat"

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
    # Saturn depends on Mars (Node.js, Python) for AI tools
    echo "mars"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# check_nodejs: Ensure Node.js is available
check_nodejs() {
    if ! command_exists node; then
        error "Node.js is not installed"
        log "Please install Mars planet first for Node.js support"
        return 1
    fi
    return 0
}

# check_npm: Ensure npm is available
check_npm() {
    if ! command_exists npm; then
        error "npm is not installed"
        return 1
    fi
    return 0
}

# install_claude_code: Install Claude Code CLI
install_claude_code() {
    step "Installing Claude Code CLI"

    if command_exists claude; then
        log "Claude Code already installed"
        return 0
    fi

    if ! check_npm; then
        return 1
    fi

    npm install -g @anthropic-ai/claude-code
    success "Claude Code CLI installed"
}

# clone_claude_repos: Clone Claude Code repositories
clone_claude_repos() {
    step "Cloning Claude Code repositories"

    local repos_dir="$VIBE_DIR/repos"
    ensure_dir "$repos_dir"

    # Clone Claude Code repo
    if [[ -d "$repos_dir/claude-code" ]]; then
        log "Claude Code repo already exists, pulling latest..."
        (cd "$repos_dir/claude-code" && git pull 2>/dev/null || true)
    else
        log "Cloning Claude Code repository..."
        git clone https://github.com/anthropics/claude-code.git "$repos_dir/claude-code" 2>/dev/null || true
    fi

    success "Claude Code repositories cloned"
}

# install_mcp_servers: Install MCP servers
install_mcp_servers() {
    step "Installing MCP (Model Context Protocol) Servers"

    if ! check_npm; then
        return 1
    fi

    local mcp_servers=(
        "@modelcontextprotocol/server-filesystem"
        "@modelcontextprotocol/server-github"
        "@modelcontextprotocol/server-postgres"
        "@modelcontextprotocol/server-sqlite"
        "@modelcontextprotocol/server-memory"
        "@modelcontextprotocol/server-brave-search"
        "@modelcontextprotocol/server-puppeteer"
        "@modelcontextprotocol/server-fetch"
    )

    for server in "${mcp_servers[@]}"; do
        if npm list -g "$server" &>/dev/null; then
            log "$server already installed"
        else
            log "Installing $server..."
            npm install -g "$server" 2>/dev/null || true
        fi
    done

    success "MCP servers installed"
}

# configure_mcp_servers: Create MCP configuration
configure_mcp_servers() {
    step "Configuring MCP servers"

    local config_dir="$HOME/.config/claude-code"
    ensure_dir "$config_dir"

    local config_file="$config_dir/mcp-servers.json"

    if [[ -f "$config_file" ]]; then
        log "MCP config already exists, backing up"
        cp "$config_file" "${config_file}.backup_$(date +%s)"
    fi

    cat > "$config_file" << 'MCP'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home"],
      "env": {}
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
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {}
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"],
      "env": {}
    },
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "./mydb.sqlite"],
      "env": {}
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "env": {}
    }
  }
}
MCP

    success "MCP configuration created"
}

# install_aichat: Install aichat (multi-model CLI)
install_aichat() {
    step "Installing aichat (multi-model AI CLI)"

    if command_exists aichat; then
        log "aichat already installed"
        return 0
    fi

    # Check if Homebrew is available
    if command_exists brew; then
        brew install aichat
        success "aichat installed"
    else
        warn "Homebrew not found, skipping aichat installation"
    fi
}

# configure_shell_aliases: Add convenient aliases
configure_shell_aliases() {
    step "Adding shell aliases"

    local aliases_file="$HOME/.vibe-palace/saturn_aliases.sh"

    cat > "$aliases_file" << 'ALIASES'
# Vibe Palace - Saturn AI Aliases
alias cc='claude'
alias claude='claude'
alias ac='aichat'
ALIASES

    success "Shell aliases created"
    log ""
    log "Add the following to your ~/.bashrc or ~/.zshrc:"
    log "  source ~/.vibe-palace/saturn_aliases.sh"
}

# planet_install: Main installation logic
planet_install() {
    banner "🌙 SATURN: AI Development"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Saturn already installed, skipping..."
        return 0
    fi

    # Check for Node.js
    if ! check_nodejs; then
        return 1
    fi

    # Install Claude Code CLI
    install_claude_code

    # Clone Claude Code repositories
    clone_claude_repos

    # Install MCP servers
    install_mcp_servers

    # Configure MCP servers
    configure_mcp_servers

    # Install aichat
    install_aichat

    # Configure shell aliases
    configure_shell_aliases

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Saturn installation complete!"
    log ""
    log "Installed tools:"
    log "  • Claude Code CLI (claude)"
    log "  • MCP Servers (filesystem, github, memory, fetch, etc.)"
    log "  • aichat (multi-model CLI)"
    log ""
    log "Next steps:"
    log "  1. Set up API keys:"
    log "     export ANTHROPIC_API_KEY='your-key'"
    log "     export OPENAI_API_KEY='your-key' (for aichat)"
    log "     export GITHUB_TOKEN='your-token' (for GitHub MCP)"
    log "     export BRAVE_API_KEY='your-key' (for Brave search MCP)"
    log ""
    log "  2. Source aliases in your shell config:"
    log "     source ~/.vibe-palace/saturn_aliases.sh"
    log ""
    log "  3. Start using Claude Code:"
    log "     claude"
    log ""
    log "  4. Edit MCP config if needed:"
    log "     nvim ~/.config/claude-code/mcp-servers.json"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🌙 Uninstalling Saturn"

    # Check if installed
    if ! planet_is_installed; then
        warn "Saturn not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Saturn tools"

    # Remove Claude Code CLI
    if command_exists npm; then
        if npm list -g @anthropic-ai/claude-code &>/dev/null; then
            log "Uninstalling Claude Code CLI..."
            npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
            success "Claude Code CLI removed"
        fi
    fi

    # Remove MCP servers
    if command_exists npm; then
        step "Removing MCP servers"
        local mcp_servers=(
            "@modelcontextprotocol/server-filesystem"
            "@modelcontextprotocol/server-github"
            "@modelcontextprotocol/server-postgres"
            "@modelcontextprotocol/server-sqlite"
            "@modelcontextprotocol/server-memory"
            "@modelcontextprotocol/server-brave-search"
            "@modelcontextprotocol/server-puppeteer"
            "@modelcontextprotocol/server-fetch"
        )

        for server in "${mcp_servers[@]}"; do
            if npm list -g "$server" &>/dev/null; then
                log "Uninstalling $server..."
                npm uninstall -g "$server" 2>/dev/null || true
            fi
        done
        success "MCP servers removed"
    fi

    # Remove aichat
    if command_exists brew; then
        if brew list aichat &>/dev/null; then
            log "Uninstalling aichat..."
            brew uninstall aichat 2>/dev/null || true
            success "aichat removed"
        fi
    fi

    # Backup and remove configs
    step "Backing up configs"
    local backup_dir="$VIBE_DIR/saturn_backup_$(date +%s)"

    if [[ -d "$HOME/.config/claude-code" ]]; then
        ensure_dir "$backup_dir"
        cp -r "$HOME/.config/claude-code" "$backup_dir/"
        rm -rf "$HOME/.config/claude-code"
        log "Backed up and removed: ~/.config/claude-code"
    fi

    # Remove Claude Code repos
    if [[ -d "$VIBE_DIR/repos/claude-code" ]]; then
        rm -rf "$VIBE_DIR/repos/claude-code"
        log "Removed: Claude Code repository"
    fi

    # Remove aliases file
    if [[ -f "$HOME/.vibe-palace/saturn_aliases.sh" ]]; then
        rm -f "$HOME/.vibe-palace/saturn_aliases.sh"
        log "Removed: saturn_aliases.sh"
    fi

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Saturn uninstalled"
    log "Configs backed up to: $backup_dir"
    log ""
    log "NOTE: Mars (Node.js, Python) was NOT removed"
    log "      Each planet is independent!"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Saturn health..."

    # Check Claude Code CLI
    if command_exists claude; then
        success "Claude Code CLI installed"
    else
        error "Claude Code CLI not found in PATH"
        ((failed++))
    fi

    # Check MCP servers
    if command_exists npm; then
        local mcp_count=0
        local mcp_servers=(
            "@modelcontextprotocol/server-filesystem"
            "@modelcontextprotocol/server-github"
            "@modelcontextprotocol/server-memory"
            "@modelcontextprotocol/server-fetch"
        )

        for server in "${mcp_servers[@]}"; do
            if npm list -g "$server" &>/dev/null; then
                ((mcp_count++))
            fi
        done

        if [[ $mcp_count -gt 0 ]]; then
            success "MCP servers installed: $mcp_count servers"
        else
            warn "No MCP servers found"
        fi
    else
        warn "npm not found, cannot check MCP servers"
    fi

    # Check MCP config
    if [[ -f "$HOME/.config/claude-code/mcp-servers.json" ]]; then
        success "MCP configuration exists"
    else
        warn "MCP configuration not found"
    fi

    # Check aichat
    if command_exists aichat; then
        success "aichat installed"
    else
        warn "aichat not found (optional)"
    fi

    # Check aliases file
    if [[ -f "$HOME/.vibe-palace/saturn_aliases.sh" ]]; then
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

    success "Saturn is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists claude && \
        [[ -f "$HOME/.config/claude-code/mcp-servers.json" ]] && \
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
