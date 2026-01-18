# Vibe Palace ☀️

> **Transform your development environment into a Solar System of modular, installable components.**

Vibe Palace is a modular development environment installer built around a "Solar System" architecture. Each component (planet) is independently installable, dependency-aware, and fully reversible.

## ✨ Features

- 🪐 **Modular Architecture**: Install only what you need
- 🔄 **Dependency Management**: Automatic dependency resolution
- 💾 **Backup & Restore**: Cross-machine migration support
- 🏥 **Health Checks**: Verify installation integrity
- 🎯 **Idempotent**: Safe to run multiple times
- ⏪ **Rollback Capability**: Clean uninstallation

## 🚀 Quick Start

### Prerequisites

- Linux or macOS
- Bash 4.0+
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/vibe-palace.git
cd vibe-palace

# Make the CLI executable
chmod +x vibe

# Optional: Add to PATH
sudo ln -s $(pwd)/vibe /usr/local/bin/vibe
```

### Basic Usage

```bash
# Install terminal tools (starship, eza, fzf, etc.)
./vibe install mercury

# Install editors (Neovim + LazyVim)
./vibe install venus

# Install programming languages (Node.js, Python, Rust, Go)
./vibe install mars

# See what's installed
./vibe status

# Run health checks
./vibe doctor

# Install everything
./vibe install --all
```

## 🪐 The Solar System

```
                    ☀️ VIBE STAR (core)
                         |
        ┌────────────────┼────────────────┐
        │                │                │
      🪐 MERCURY       🌍 VENUS         🔭 MARS
    (Terminal)       (Editors)        (Languages)
        │                │                │
      🪐 JUPITER       🌙 SATURN        💫 URANUS
    (Databases)     (AI Tools)       (Dev Tools)
        │                │                │
      🌑 NEPTUNE       ☄️ PLUTO
    (Containers)    (Extras)
```

### Planets Overview

| Planet | Purpose | Duration | Tools |
|--------|---------|----------|-------|
| 🪐 [Mercury](docs/PLANETS.md#-mercury-terminal-foundation) | Terminal Foundation | ~5 min | starship, zoxide, eza, bat, fzf, tmux |
| 🌍 [Venus](docs/PLANETS.md#-venus-editors--ides) | Editors & IDEs | ~10 min | Neovim, LazyVim, JetBrains Mono |
| 🔭 [Mars](docs/PLANETS.md#-mars-programming-languages) | Programming Languages | ~15 min | fnm, pyenv, rustup, Go |
| 🪐 [Jupiter](docs/PLANETS.md#-jupiter-databases) | Databases | ~8 min | PostgreSQL, MySQL, Redis, MongoDB |
| 🌙 [Saturn](docs/PLANETS.md#-saturn-ai-development) | AI Development | ~5 min | Claude Code, aichat, MCP |
| 💫 [Uranus](docs/PLANETS.md#-uranus-dev-tools) | Dev Tools | ~10 min | Git, lazygit, Docker, jq |
| 🌑 [Neptune](docs/PLANETS.md#-neptune-containers--orchestration) | Containers | ~12 min | Kubernetes, Helm, Podman |
| ☄️ [Pluto](docs/PLANETS.md#-pluto-bonus-tools) | Bonus Tools | ~5 min | Zsh, Oh My Zsh, Atuin |

## 📚 Documentation

- [**Architecture**](docs/ARCHITECTURE.md) - System design and components
- [**Planets**](docs/PLANETS.md) - Detailed planet descriptions
- [**Contributing**](docs/CONTRIBUTING.md) - How to contribute
- [**Backup & Restore**](docs/BACKUP_RESTORE.md) - Backup/restore guide
- [**Testing**](docs/TESTING.md) - Testing guide
- [**Migration Guide**](docs/MIGRATION.md) - Migrate from palace.sh

## 🎯 Common Workflows

### Minimal Setup

Essential tools for development:

```bash
./vibe install mercury    # Terminal tools
./vibe install venus      # Editor (Neovim)
./vibe install uranus     # Git, Docker, etc.
```

### Web Development

Full-stack web development:

```bash
./vibe install mercury
./vibe install venus
./vibe install mars       # Node.js, Python
./vibe install jupiter    # Databases
```

### AI Development

AI and ML tools:

```bash
./vibe install mercury
./vibe install mars       # Required for AI tools
./vibe install saturn     # AI tools
```

### DevOps / Containers

Container orchestration:

```bash
./vibe install mercury
./vibe install uranus     # Docker basics
./vibe install neptune    # Kubernetes, Helm
```

### Complete Setup

Everything installed:

```bash
./vibe install --all
```

## 💾 Backup & Restore

### Backup Your Setup

```bash
# Full backup (configs + state)
./vibe backup

# Config-only backup
./vibe backup --configs

# List backups
./vibe backup --list
```

### Restore on New Machine

```bash
# On new machine
git clone https://github.com/your-username/vibe-palace.git
cd vibe-palace

# Restore from backup
./vibe restore /path/to/vibe-backup-*.tar.gz
```

Perfect for setting up a new machine or syncing multiple machines!

## 🔧 Commands

```bash
# Installation
./vibe install <planet>       # Install specific planet
./vibe install --all          # Install all planets
./vibe uninstall <planet>     # Remove planet

# Information
./vibe list                   # List all planets
./vibe status                 # Show installed planets
./vibe tree <planet>          # Show dependency tree
./vibe graph                  # Show full dependency graph

# Health & Maintenance
./vibe doctor                 # Run health checks
./vibe backup                 # Create backup
./vibe restore <file>         # Restore from backup

# Options
--dry-run, -n                 # Show what would be done
--verbose, -v                 # Detailed output
--quiet, -q                   # Suppress non-errors
--yes, -y                     # Auto-confirm prompts
```

## 🏥 Health Checks

Verify your installation:

```bash
./vibe doctor
```

Output:
```
🏥 Vibe Palace Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking mercury...
✓ starship installed
✓ eza installed
✓ fzf installed
✓ All systems operational!

Checking venus...
✓ nvim installed
✓ LazyVim configured
✓ All systems operational!

All systems operational!
```

## 🌳 Dependency Management

Planets automatically handle dependencies:

```bash
# Saturn depends on Mars, which depends on Mercury
./vibe install saturn

# Output:
# Installation plan (3 planet(s)):
#   • mercury (new)
#   • mars (new)
#   • saturn (new)

# Mercury installs first, then Mars, then Saturn
```

View dependency relationships:

```bash
./vibe tree saturn
# saturn
# └── mars
#     └── mercury
```

## 🧪 Testing

Run tests:

```bash
# Quick smoke tests
./tests/quick_test.sh

# Full test suite (requires bats)
bats tests/

# Specific tests
bats tests/test_lib.sh
bats tests/test_planets.sh
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Adding a New Planet

1. Create `planets/your-planet.sh`
2. Implement required functions
3. Add tests in `tests/test_planets.sh`
4. Update documentation
5. Submit a pull request

See [CONTRIBUTING.md](docs/CONTRIBUTING.md#adding-a-new-planet) for details.

## 🐛 Troubleshooting

### Installation Fails

1. Check dependencies: `./vibe tree <planet>`
2. Run health check: `./vibe doctor`
3. Try reinstalling: `./vibe uninstall <planet> && ./vibe install <planet>`

### Planet Not Found

```bash
# List available planets
./vibe list

# Verify planet file exists
ls planets/*.sh
```

### Permission Issues

```bash
# Make vibe executable
chmod +x vibe

# Or install to /usr/local/bin
sudo ln -s $(pwd)/vibe /usr/local/bin/vibe
```

### More Help

See the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for more solutions.

## 📖 Examples

Check the `examples/` directory for:

- [Custom Planet Example](examples/custom-planet.sh) - How to create your own planet
- [Workflow Examples](examples/workflow.sh) - Common usage patterns
- [Integration Scripts](examples/) - Integration with other tools

## 🔮 Roadmap

- [ ] Configuration profiles (work vs personal)
- [ ] Progress bars for installations
- [ ] Plugin system for custom planets
- [ ] Planet registry/manifest
- [ ] Auto-update notifications
- [ ] Web UI for planet discovery

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by the need for modular development environments
- Built with love for the developer community
- Powered by the Solar System architecture

## 📞 Support

- 📖 [Documentation](docs/)
- 🐛 [Issues](https://github.com/your-username/vibe-palace/issues)
- 💬 [Discussions](https://github.com/your-username/vibe-palace/discussions)

---

**Made with ❤️ by the Vibe Palace community**

Transform your development environment into a well-organized Solar System today! 🚀
