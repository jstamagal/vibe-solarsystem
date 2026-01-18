# Vibe Palace Planets

## Overview

The Vibe Solar System consists of 8 planets, each providing a specific set of development tools. Planets can be installed independently, and the system automatically handles dependencies.

## Planet Summary

| Planet | Purpose | Duration | Dependencies |
|--------|---------|----------|--------------|
| 🪐 Mercury | Terminal Foundation | ~5 min | None |
| 🌍 Venus | Editors & IDEs | ~10 min | Mercury |
| 🔭 Mars | Programming Languages | ~15 min | Mercury |
| 🪐 Jupiter | Databases | ~8 min | Mercury |
| 🌙 Saturn | AI Development | ~5 min | Mars, Mercury |
| 💫 Uranus | Dev Tools | ~10 min | Mercury |
| 🌑 Neptune | Containers | ~12 min | Uranus, Mercury |
| ☄️ Pluto | Bonus Tools | ~5 min | Mercury |

## Dependency Graph

```
                    mercury (foundation)
                         |
        ┌────────────────┼────────────────┐
        │                │                │
      venus            mars            jupiter
        │                │                │
        │         ┌──────┴──────┐         │
        │         │             │         │
     saturn      uranus       pluto
                      │
                      │
                  neptune
```

---

## 🪐 Mercury: Terminal Foundation

**Description**: Core terminal experience and productivity tools

**Version**: 1.0.0
**Duration**: ~5 minutes
**Dependencies**: None (base planet)

### Tools Installed

1. **Starship** - Cross-shell prompt
   - Fast, customizable prompt
   - Git status, language versions, and more
   - Config: `~/.config/starship.toml`

2. **Zoxide** - Smarter cd command
   - Remembers frequently used directories
   - Fuzzy matching with `z` command

3. **eza** - Modern ls replacement
   - Colors, git status, tree view
   - Aliases: `ls`, `ll`, `la`

4. **bat** - Enhanced cat clone
   - Syntax highlighting
   - Line numbers, git integration
   - Alias: `cat`

5. **delta** - Syntax-highlighting pager for git
   - Better diff viewing
   - Configured in `~/.gitconfig`

6. **fzf** - Command-line fuzzy finder
   - Fuzzy search anything
   - Integrations with history, files

7. **ripgrep (rg)** - Fast grep alternative
   - Recursive search by default
   - Respects .gitignore

8. **fd** - Fast find alternative
   - Friendly syntax
   - Colorized output

9. **tmux** - Terminal multiplexer
   - Session management
   - Split panes, windows

10. **TPM** - Tmux Plugin Manager
    - Plugin management for tmux
    - Auto-install plugins

### Installation

```bash
vibe install mercury
```

### Health Checks

- ✅ Starship in PATH
- ✅ eza, bat, fzf installed
- ✅ tmux configured
- ✅ ~/.config/starship.toml exists

### Configurations Created

- `~/.config/starship.toml` - Starship prompt config
- `~/.tmux.conf` - Tmux configuration
- Shell aliases in `~/.bashrc` or `~/.zshrc`

### Uninstallation

```bash
vibe uninstall mercury
```

**Warning**: Many other planets depend on Mercury. Uninstall Mercury only if you're removing all planets.

---

## 🌍 Venus: Editors & IDEs

**Description**: Modern development environments

**Version**: 1.0.0
**Duration**: ~10 minutes
**Dependencies**: Mercury

### Tools Installed

1. **Neovim 0.11+** - Modern vim-based editor
   - Lua-based configuration
   - LSP support built-in
   - High performance

2. **LazyVim** - Pre-configured Neovim distro
   - Lazy-loaded plugins
   - Sensible defaults
   - Easy customization

3. **JetBrains Mono** - Beautiful coding font
   - Ligatures support
   - Excellent readability

### Installation

```bash
vibe install venus
```

**Note**: This will auto-install Mercury first if not already installed.

### Health Checks

- ✅ nvim in PATH
- ✅ LazyVim installed
- ✅ ~/.config/nvim exists
- ✅ JetBrains Mono font installed

### Configurations Created

- `~/.config/nvim/` - Neovim configuration
  - LazyVim distro
  - Custom settings in `lua/custom/`

### Usage

```bash
nvim                    # Launch Neovim
nvim file.txt           # Edit file
nvim .                  # Open file explorer
```

### Uninstallation

```bash
vibe uninstall venus
```

---

## 🔭 Mars: Programming Languages

**Description**: Language runtimes and version managers

**Version**: 1.0.0
**Duration**: ~15 minutes
**Dependencies**: Mercury

### Tools Installed

1. **fnm** - Fast Node Manager
   - Node.js version management
   - Per-directory version switching
   - Fast and lightweight

2. **pyenv** - Python version manager
   - Multiple Python versions
   - Virtual environment support
   - Project-specific versions

3. **rustup** - Rust toolchain installer
   - Rust compiler (rustc)
   - Cargo package manager
   - Toolchain management

4. **Go** - Go programming language
   - Go compiler toolchain
   - Modern development experience

5. **Java** (Optional) - OpenJDK
   - Java Development Kit
   - Maven/Gradle support

### Installation

```bash
vibe install mars
```

### Health Checks

- ✅ fnm in PATH
- ✅ pyenv in PATH
- ✅ rustc, cargo installed
- ✅ go installed

### Usage

```bash
# Node.js
fnm list-remote        # List available Node versions
fnm install 20         # Install Node 20
fnm use 20             # Use Node 20 in current shell

# Python
pyenv versions         # List installed Python versions
pyenv install 3.12     # Install Python 3.12
pyenv global 3.12      # Set global version

# Rust
rustc --version        # Check Rust version
cargo new project      # Create new project

# Go
go version             # Check Go version
go mod init example    # Initialize module
```

### Uninstallation

```bash
vibe uninstall mars
```

---

## 🪐 Jupiter: Databases

**Description**: Database clients and tools

**Version**: 1.0.0
**Duration**: ~8 minutes
**Dependencies**: Mercury

### Tools Installed

1. **PostgreSQL Client** - psql + pgcli
   - Command-line Postgres interface
   - Enhanced CLI with auto-completion

2. **MySQL Client** - mysql + mycli
   - MySQL/MariaDB client
   - Feature-rich CLI

3. **Redis** + iredis
   - In-memory data structure store
   - Interactive Redis CLI

4. **MongoDB Shell** - mongosh
   - Modern MongoDB CLI
   - JavaScript-based interface

5. **SQLite** - sqlite3
   - Embedded database
   - Simple file-based DB

### Installation

```bash
vibe install jupiter
```

### Health Checks

- ✅ psql, pgcli installed
- ✅ mysql, mycli installed
- ✅ redis-cli, iredis installed
- ✅ mongosh installed
- ✅ sqlite3 installed

### Usage

```bash
# PostgreSQL
psql -h localhost -U user -d database

# MySQL
mysql -h localhost -u user -p database

# Redis
redis-cli
iredis

# MongoDB
mongosh "mongodb://localhost:27017"

# SQLite
sqlite3 database.db
```

### Uninstallation

```bash
vibe uninstall jupiter
```

---

## 🌙 Saturn: AI Development

**Description**: AI coding assistants and tools

**Version**: 1.0.0
**Duration**: ~5 minutes
**Dependencies**: Mars, Mercury

### Tools Installed

1. **Claude Code** - Anthropic's AI coding assistant
   - Advanced code understanding
   - Multi-file editing
   - Interactive development

2. **aichat** - Universal AI chat CLI
   - Multiple provider support
   - ChatGPT, Claude, and more
   - Configurable prompts

3. **MCP Servers** - Model Context Protocol
   - Extensible AI tool protocol
   - Custom server support

### Installation

```bash
vibe install saturn
```

**Note**: Requires Mars (Node.js, Python) to be installed first.

### Health Checks

- ✅ claude installed
- ✅ aichat installed
- ✅ MCP config exists

### Usage

```bash
# Claude Code
claude "Explain this code"

# aichat
aichat "Help me debug this"

# With pipe
echo "code" | claude "review this"
```

### Configuration

- `~/.config/aichat/` - aichat configuration
- `~/.config/claude/` - Claude Code settings
- API keys must be configured separately

### Uninstallation

```bash
vibe uninstall saturn
```

---

## 💫 Uranus: Dev Tools

**Description**: Essential development utilities

**Version**: 1.0.0
**Duration**: ~10 minutes
**Dependencies**: Mercury

### Tools Installed

1. **Git** - Version control
   - Latest stable Git
   - Enhanced configuration

2. **lazygit** - Terminal UI for Git
   - Interactive Git operations
   - Beautiful TUI interface

3. **gh** - GitHub CLI
   - GitHub from command line
   - PRs, issues, releases

4. **Docker** - Container platform
   - Container management
   - Docker Compose

5. **lazydocker** - TUI for Docker
   - Interactive Docker management
   - Visual container control

6. **jq** - JSON processor
   - JSON parsing and manipulation

7. **yq** - YAML processor
   - YAML parsing and manipulation

8. **httpie** - User-friendly HTTP client
   - Modern curl alternative
   - Syntax highlighting

9. **gum** - Interactive CLI tools
   - Choose, input, confirm, etc.
   - From Charmbracelet

### Installation

```bash
vibe install uranus
```

### Health Checks

- ✅ git, lazygit installed
- ✅ gh installed and authenticated
- ✅ docker installed
- ✅ lazydocker installed
- ✅ jq, yq, httpie installed
- ✅ gum installed

### Usage

```bash
# Git
git status
lazygit                 # Interactive Git UI

# GitHub
gh pr list             # List pull requests
gh pr create           # Create PR

# Docker
docker ps
lazydocker             # Interactive Docker UI

# JSON/YAML
echo '{"foo": "bar"}' | jq .
cat config.yaml | yq '.version'

# HTTP
http GET https://api.github.com/users/github
http POST https://api.example.com data=value
```

### Uninstallation

```bash
vibe uninstall uranus
```

**Warning**: Neptune depends on Uranus.

---

## 🌑 Neptune: Containers & Orchestration

**Description**: Container ecosystems and orchestration

**Version**: 1.0.0
**Duration**: ~12 minutes
**Dependencies**: Uranus, Mercury

### Tools Installed

1. **Docker** - Container platform (extended)
   - Already installed via Uranus
   - Additional configuration

2. **Docker Compose** - Multi-container apps
   - YAML-based orchestration
   - Development environments

3. **kubectl** - Kubernetes CLI
   - Kubernetes cluster management
   - Deployment control

4. **helm** - Kubernetes package manager
   - Chart management
   - Release management

5. **kind** - Kubernetes in Docker
   - Local k8s for testing
   - CI/CD integration

6. **minikube** - Local Kubernetes
   - Development cluster
   - Add-on support

7. **podman** - Docker alternative
   - Daemonless containers
   - Rootless operation

### Installation

```bash
vibe install neptune
```

**Note**: Requires Uranus (which requires Mercury).

### Health Checks

- ✅ kubectl installed
- ✅ helm installed
- ✅ kind/minikube installed
- ✅ podman installed
- ✅ Docker Compose installed

### Usage

```bash
# Kubernetes
kubectl get pods
kubectl apply -f deployment.yaml

# Helm
helm install myapp ./chart
helm list

# kind
kind create cluster
kind get clusters

# minikube
minikube start
minikube dashboard

# podman
podman run -it ubuntu bash
podman ps
```

### Uninstallation

```bash
vibe uninstall neptune
```

---

## ☄️ Pluto: Bonus Tools

**Description**: Extra utilities and enhancements

**Version**: 1.0.0
**Duration**: ~5 minutes
**Dependencies**: Mercury

### Tools Installed

1. **Zsh** - Extended shell
   - Better than Bash
   - Advanced features

2. **Oh My Zsh** - Zsh framework
   - Plugin system
   - Theme support

3. **Atuin** - Shell history sync
   - Better shell history
   - Sync across machines
   - Encrypted storage

4. **tldr** - Simplified man pages
   - Community-maintained
   - Practical examples
   - Multiple languages

5. ** Various CLI toys** - Fun utilities
   - Terminal entertainment
   - Productivity enhancers

### Installation

```bash
vibe install pluto
```

### Health Checks

- ✅ zsh installed
- ✅ Oh My Zsh installed
- ✅ atuin installed
- ✅ tldr installed

### Usage

```bash
# Switch to Zsh
chsh -s $(which zsh)

# Atuin
atuin search          # Search history
atuin sync            # Sync to cloud

# tldr
tldr tar              # Simplified tar help
tldr docker           # Docker examples
```

### Uninstallation

```bash
vibe uninstall pluto
```

---

## Installation Strategies

### Minimal Setup

Essential tools only:
```bash
vibe install mercury
vibe install uranus
```

### Web Development

Frontend and backend:
```bash
vibe install mercury
vibe install venus
vibe install mars
vibe install uranus
```

### Full Stack Developer

Complete development environment:
```bash
vibe install --all
```

Or step-by-step:
```bash
vibe install mercury    # Terminal
vibe install venus      # Editor
vibe install mars       # Languages
vibe install uranus     # Dev tools
vibe install jupiter    # Databases
```

### AI Development

Focus on AI tools:
```bash
vibe install mercury
vibe install mars       # Needed for AI tools
vibe install saturn
```

### DevOps Engineer

Containers and orchestration:
```bash
vibe install mercury
vibe install uranus     # Docker basics
vibe install neptune    # Full k8s stack
```

## Troubleshooting

### Installation Fails

1. Check dependencies: `vibe tree <planet>`
2. Run health check: `vibe doctor`
3. Check logs in `~/.vibe-palace/logs/`

### Planet Not Found

- Verify planet name: `vibe list`
- Check if planet file exists: `ls planets/*.sh`

### Dependency Issues

- View dependency tree: `vibe tree <planet>`
- Install dependencies manually if needed
- Check for circular dependencies

### Uninstall Fails

1. Check dependent planets: `vibe list`
2. Uninstall dependents first
3. Use `--yes` to force if needed

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to add a planet
- [TESTING.md](TESTING.md) - Testing guide
