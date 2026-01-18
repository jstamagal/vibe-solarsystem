# Vibe Solar System - Product Requirements Document

## Executive Summary
Transform the monolithic `palace.sh` (1104 lines) into a modular, extensible "Solar System" architecture where each planet represents a discrete, installable component with proper dependency management, rollback capabilities, and composable design.

## Current State Analysis

### Problems with palace.sh
- **Monolithic**: 1104 lines in a single file, hard to maintain
- **All-or-nothing**: Must run entire script or nothing
- **No rollback**: If something fails, difficult to recover
- **Tightly coupled**: All phases depend on each other
- **No modularity**: Can't install just Node.js without Docker
- **Idempotency issues**: Some checks exist but not comprehensive
- **Testing impossible**: Can't test individual components

### Vision: The Solar System Architecture
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

Each planet is:
1. **Independent**: Can be installed separately
2. **Idempotent**: Safe to run multiple times
3. **Rollback-capable**: Can uninstall cleanly
4. **Dependency-aware**: Declares what it needs
5. **Testable**: Has health checks
6. **Documented**: Has its own README

## Requirements

### Core Requirements (MUST)

#### R1: Modular Architecture
- Each major component becomes a standalone "planet" script
- Planets located in `planets/` directory
- Each planet is a self-contained bash script
- Common utilities in `lib/` directory
- No code duplication between planets

#### R2: Orbit Controller (Main CLI)
- `vibe` command with subcommands
- Examples:
  - `vibe install mercury`       # Install terminal tools
  - `vibe install venus nvim`    # Install specific editor
  - `vibe install --all`         # Full solar system
  - `vibe status`                # Show installed planets
  - `vibe uninstall jupiter`     # Remove database tools
  - `vibe update`                # Update all installed
  - `vibe doctor`                # Health check

#### R3: Dependency Management
- Each planet declares dependencies
- Automatic dependency resolution
- Install order calculated automatically
- Dependency graph visualization
- Circular dependency detection

#### R4: State Management
- Track what's installed where
- `~/.vibe-palace/state.json` for installation state
- Version tracking for each planet
- Checksum verification for downloads
- Installation logs per planet

#### R5: Idempotency & Safety
- Every operation is idempotent
- Pre-flight checks before any install
- Backup existing configs before overwriting
- Dry-run mode with `--dry-run`
- Confirmation prompts for destructive operations

#### R6: Rollback Capability
- `vibe rollback [planet]` to uninstall
- Remove binaries, configs, and packages
- Restore backed-up configs
- Clean up state files
- Post-rollback verification

#### R7: Health Checks
- `vibe doctor` runs all planet health checks
- Each planet has `check_health()` function
- Verify binaries exist in PATH
- Verify configs are valid
- Test basic functionality
- Report issues with fixes

### Nice-to-Have (SHOULD)

#### R8: Configuration
- User config file `~/.vibe-palace/config.toml`
- Override default behavior
- Set install paths
- Enable/disable specific tools
- Custom planets path

#### R9: Plugin System
- Support user-defined planets
- `~/.vibe-palace/planets/` for custom planets
- Shareable planet packages
- Planet registry/manifest

#### R10: Progress Reporting
- Visual progress bars
- Per-planet installation time
- Total time estimate
- Colored output for status
- Verbose/quiet modes

#### R11: Backup & Restore
- `vibe backup` saves entire state
- `vibe restore <file>` restores
- Cross-machine migration
- Config-only backup option

#### R12: Testing
- Unit tests for each planet
- Integration tests for orbits
- Mock mode for testing
- CI/CD pipeline

## Planet Breakdown

### 🪐 MERCURY: Terminal Foundation
**Purpose**: Core terminal experience
**Duration**: ~5 min
**Tools**:
- Starship prompt
- Zoxide
- eza, bat, delta
- fzf, ripgrep, fd
- tmux + TPM

**Dependencies**: None
**Interactions**: All planets use these tools

### 🌍 VENUS: Editors & IDEs
**Purpose**: Development environments
**Duration**: ~10 min
**Tools**:
- Neovim 0.11+ + LazyVim
- Helix (optional)
- JetBrains Mono font

**Dependencies**: MERCURY
**Interactions**: None

### 🔭 MARS: Programming Languages
**Purpose**: Language runtimes & package managers
**Duration**: ~15 min
**Tools**:
- fnm (Node.js)
- pyenv (Python)
- rustup (Rust)
- Go (brew)
- Java (optional)

**Dependencies**: MERCURY
**Interactions**: VENUS (editors need language servers)

### 🪐 JUPITER: Databases
**Purpose**: Database clients & tools
**Duration**: ~8 min
**Tools**:
- PostgreSQL client + pgcli
- MySQL client + mycli
- Redis + iredis
- MongoDB shell
- SQLite

**Dependencies**: MERCURY
**Interactions**: MARS (language drivers)

### 🌙 SATURN: AI Development
**Purpose**: AI coding assistants
**Duration**: ~5 min
**Tools**:
- Claude Code
- OpenAI Codex CLI
- aichat
- MCP Servers

**Dependencies**: MARS (Node.js, Python)
**Interactions**: VENUS (editor integration)

### 💫 URANUS: Dev Tools
**Purpose**: Development utilities
**Duration**: ~10 min
**Tools**:
- Git + lazygit + gh
- Docker
- lazydocker
- jq, yq, httpie
- gum, charmbracelet tools

**Dependencies**: MERCURY
**Interactions**: MARS (language-specific tools)

### 🌑 NEPTUNE: Containers & Orchestration
**Purpose**: Container ecosystems
**Duration**: ~12 min
**Tools**:
- Docker + Docker Compose
- kubectl + helm
- kind/minikube
- podman

**Dependencies**: URANUS (dev tools)
**Interactions**: JUPITER (databases)

### ☄️ PLUTO: Bonus Tools
**Purpose**: Extra utilities
**Duration**: ~5 min
**Tools**:
- Zsh + Oh My Zsh
- Atuin
- tldr
- various CLI toys

**Dependencies**: MERCURY
**Interactions**: None

## File Structure

```
vibe-palace/
├── vibe                           # Main CLI (orbit controller)
├── lib/
│   ├── core.sh                    # Core functions (log, success, error, etc.)
│   ├── state.sh                   # State management
│   ├── deps.sh                    # Dependency resolution
│   ├── backup.sh                  # Backup/restore
│   └── health.sh                  # Health check framework
├── planets/
│   ├── mercury.sh                 # Terminal tools
│   ├── venus.sh                   # Editors
│   ├── mars.sh                    # Languages
│   ├── jupiter.sh                 # Databases
│   ├── saturn.sh                  # AI tools
│   ├── uranus.sh                  # Dev tools
│   ├── neptune.sh                 # Containers
│   └── pluto.sh                   # Extras
├── tests/
│   ├── test_lib.sh                # Library tests
│   ├── test_planets.sh            # Planet tests
│   └── integration.sh             # Full system tests
├── docs/
│   ├── ARCHITECTURE.md            # Architecture docs
│   ├── PLANETS.md                 # Planet descriptions
│   └── CONTRIBUTING.md            # Contribution guide
├── palace.sh                      # Legacy monolith (keep for reference)
└── README.md                      # Main documentation
```

## Success Criteria

1. **Modularity**: Each planet installs independently
2. **Speed**: `vibe install mercury` completes in <5 min
3. **Reliability**: 99% idempotency rate
4. **Usability**: `vibe --help` is clear and comprehensive
5. **Maintainability**: Adding a new planet takes <1 hour
6. **Safety**: Zero data loss during rollback
7. **Testing**: 80%+ code coverage for lib/

## Non-Goals

- GUI applications (CLI/TUI only)
- Windows support (Linux/macOS only)
- Replacing existing package managers (use brew, apt, etc.)
- Cloud installation (local only)
- Automatic updates (manual `vibe update` only)

## Timeline

- **Phase 1**: Core architecture (lib/, vibe CLI)
- **Phase 2**: First 3 planets (Mercury, Venus, Mars)
- **Phase 3**: Remaining planets + testing
- **Phase 4**: Documentation & polish
- **Phase 5**: Community features (sharing, plugins)

## Open Questions

1. Should we use a real programming language (Python/Go) instead of bash?
2. Do we need a central registry/manifest for planets?
3. Should we support config profiles (work vs personal)?
4. Do we need telemetry/usage tracking?
5. Should planets be versioned independently?
