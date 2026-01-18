# Vibe Palace Architecture

## Overview

Vibe Palace is a modular development environment installer built around a "Solar System" architecture. Each component (planet) is independently installable, dependency-aware, and fully reversible.

## Design Philosophy

- **Modularity**: Every tool lives in its own planet
- **Independence**: Planets can be installed/uninstalled separately
- **Idempotency**: Safe to run installation multiple times
- **Safety**: Rollback capability for every planet
- **Clarity**: Clear dependency relationships

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VIBE CLI                            │
│                      (Orbit Controller)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   lib/       │  │  planets/    │  │   tests/     │
│              │  │              │  │              │
│ core.sh      │  │ mercury.sh   │  │ test_lib.sh  │
│ state.sh     │  │ venus.sh     │  │ test_*.sh    │
│ deps.sh      │  │ mars.sh      │  │              │
│ backup.sh    │  │ ...          │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Core Components

### 1. Orbit Controller (`vibe`)

Main CLI that orchestrates the entire system.

**Responsibilities:**
- Parse commands and arguments
- Calculate installation order
- Orchestrate planet installation
- Manage backup/restore operations
- Display status and health information

**Key Functions:**
- `main()` - Entry point
- `cmd_install()` - Install planet(s)
- `cmd_uninstall()` - Remove planet
- `cmd_status()` - Show installation state
- `cmd_doctor()` - Run health checks
- `cmd_backup()` - Create backup
- `cmd_restore()` - Restore from backup

### 2. Core Library (`lib/core.sh`)

Foundational utilities used by all components.

**Functions:**

#### Logging
```bash
log "message"           # Info message (blue)
success "message"       # Success message (green)
warn "message"          # Warning message (yellow)
error "message"         # Error message (red)
step "message"          # Step indicator (cyan)
banner "title"          # Section banner
```

#### Utilities
```bash
command_exists cmd      # Check if command exists
ask_yes_no prompt       # Prompt user (y/n)
confirm_dangerous_op    # Extra confirmation for dangerous ops
detect_os               # Detect Linux/macOS
```

#### Colors
- `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `BOLD`, `NC`

### 3. State Management (`lib/state.sh`)

Tracks installation state in `~/.vibe-palace/state.json`.

**State File Structure:**
```json
{
  "version": "1.0.0",
  "installed": {
    "mercury": {
      "version": "1.0.0",
      "installed_at": "2025-01-18T12:00:00Z",
      "checksum": "abc123..."
    }
  },
  "last_update": "2025-01-18T12:00:00Z"
}
```

**Functions:**
```bash
state_init              # Initialize state directory
state_add planet        # Add planet to installed
state_remove planet     # Remove planet from state
state_is_installed      # Check if planet is installed
state_get_version       # Get planet version
state_list              # List all installed planets
state_count             # Count installed planets
state_last_update       # Get last update timestamp
```

### 4. Dependency Resolution (`lib/deps.sh`)

Manages planet dependencies and calculates installation order.

**Key Concepts:**

#### Dependency Graph
Each planet declares dependencies:
```bash
planet_dependencies() {
    echo "mercury"  # Venus depends on Mercury
}
```

#### Topological Sort
Dependencies are resolved using topological sort to ensure correct installation order.

**Functions:**
```bash
deps_get planet         # Get planet's dependencies
deps_sort_topological   # Calculate install order for planet
deps_resolve_install_order # Calculate order for multiple planets
deps_show_tree planet   # Display dependency tree
deps_show_graph         # Display full dependency graph
deps_planet_exists      # Check if planet exists
deps_list_all           # List all available planets
```

**Dependency Graph (Current):**
```
mercury (none)
    ├── venus → mercury
    ├── mars → mercury
    ├── jupiter → mercury
    ├── uranus → mercury
    └── pluto → mercury
        ├── saturn → mars
        └── neptune → uranus
```

### 5. Backup System (`lib/backup.sh`)

Creates and restores backups of configurations and state.

**Backup Contents:**
- Configuration files from `~/.config/`
- State file (`~/.vibe-palace/state.json`)
- Planet metadata
- Installation manifest

**Functions:**
```bash
backup_create           # Create full backup
backup_configs_only     # Backup configs only
backup_restore file     # Restore from backup
backup_list             # List available backups
backup_validate file    # Validate backup integrity
```

**Backup File Structure:**
```
vibe-backup-20250118-120000.tar.gz
├── configs/           # Backed up config files
├── state.json         # Installation state
└── manifest.json      # Backup metadata
```

## Planet Interface

Every planet MUST implement these functions:

### Required Functions

```bash
# Metadata
planet_metadata() {
    # Returns JSON with:
    # - name: Planet name
    # - version: Planet version
    # - description: Brief description
    # - dependencies: Array of dependency planets
}

# Dependencies
planet_dependencies() {
    # Echo dependency planet names, one per line
}

# Installation
planet_install() {
    # Main installation logic
    # Return 0 on success, non-zero on failure
}

# Uninstallation
planet_uninstall() {
    # Cleanup logic
    # Remove binaries, configs, etc.
    # Return 0 on success
}

# Health Check
planet_check_health() {
    # Verify installation is healthy
    # Check binaries exist, configs valid
    # Return 0 if healthy, non-zero if not
}

# Idempotency Check
planet_is_installed() {
    # Check if already installed
    # Return 0 if installed, non-zero if not
}
```

### Planet Template

```bash
#!/usr/bin/env bash
# Planet: Example
# Description: An example planet template

set -euo pipefail

# Source core library (already sourced by vibe, but good for standalone)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/core.sh"

# Metadata
planet_metadata() {
    cat <<EOF
{
  "name": "example",
  "version": "1.0.0",
  "description": "An example planet",
  "dependencies": []
}
EOF
}

# Dependencies
planet_dependencies() {
    echo "mercury"  # If needed
}

# Installation
planet_install() {
    step "Installing example planet..."

    # Check if already installed
    if planet_is_installed; then
        log "Already installed, skipping..."
        return 0
    fi

    # Installation logic here
    log "Installing example-tool..."

    # Verify installation
    if ! command_exists example-tool; then
        error "example-tool not found in PATH"
        return 1
    fi

    # Update state
    state_add "example" "1.0.0"

    success "Example planet installed!"
    return 0
}

# Uninstallation
planet_uninstall() {
    step "Uninstalling example planet..."

    # Remove binaries
    if command_exists example-tool; then
        log "Removing example-tool..."
        # Uninstall logic here
    fi

    # Remove configs
    # ...

    # Update state
    state_remove "example"

    success "Example planet uninstalled!"
    return 0
}

# Health Check
planet_check_health() {
    step "Checking example planet..."

    # Check binary
    if ! command_exists example-tool; then
        error "example-tool not found in PATH"
        return 1
    fi

    # Check config
    if [[ ! -f ~/.config/example/config ]]; then
        warn "example config not found"
        return 1
    fi

    success "Example planet is healthy!"
    return 0
}

# Idempotency Check
planet_is_installed() {
    command_exists example-tool && \
    [[ -f ~/.config/example/config ]]
}
```

## Data Flow

### Installation Flow

```
User runs: vibe install venus
        │
        ▼
┌─────────────────────────┐
│ Parse command           │
│ Validate planet exists  │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Calculate dependencies  │
│ deps_sort_topological   │
│ Result: [mercury, venus]│
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Show installation plan  │
│ Confirm with user       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ For each planet:        │
│   1. Source planet.sh   │
│   2. Check installed?   │
│   3. planet_install()   │
│   4. Update state       │
└──────────┬──────────────┘
           │
           ▼
     Show summary
```

### Dependency Resolution Flow

```
Input: "saturn"
        │
        ▼
┌─────────────────────────┐
│ Get direct deps:        │
│ ["mars"]                │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Get mars deps:          │
│ ["mercury"]             │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Get mercury deps:       │
│ [] (base planet)        │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ Topological sort:       │
│ [mercury, mars, saturn] │
└─────────────────────────┘
```

## Error Handling

### Error Propagation

All scripts use `set -euo pipefail`:
- `-e`: Exit on error
- `-u`: Exit on undefined variable
- `-o pipefail`: Exit on pipe failure

### Error Recovery

1. **Installation Failure**: Planet stops, logs error, partial cleanup suggested
2. **Dependency Failure**: Installation halts, user informed
3. **Health Check Failure**: Planet marked as unhealthy, suggestions provided

### State Consistency

- State only updated after successful installation
- Uninstall updates state after successful cleanup
- Backup validates before writing

## Testing Architecture

### Test Structure

```
tests/
├── test_lib.sh           # Core library tests
├── test_lib_simple.sh    # Simple lib tests
├── test_planets.sh       # Planet-specific tests
├── test_deps.sh          # Dependency resolution tests
├── integration.sh        # Full system tests
└── quick_test.sh         # Fast smoke tests
```

### Test Categories

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test planet installation/uninstallation
3. **Dependency Tests**: Verify dependency resolution
4. **Health Check Tests**: Verify health check logic

## Security Considerations

### File Operations

- Always validate file paths before operations
- Backup files before overwriting
- Use checksums for downloads

### Execution Safety

- `set -euo pipefail` in all scripts
- Explicit error checking
- Confirmation prompts for destructive operations

### State Integrity

- JSON schema validation for state file
- Checksum verification for installations
- Atomic file operations where possible

## Performance Considerations

### Optimization Strategies

1. **Idempotency Checks**: Skip already installed planets
2. **Parallel Operations**: Future support for parallel independent installs
3. **Caching**: Dependency graph caching

### Typical Installation Times

- Mercury: ~5 min
- Venus: ~10 min (plus Mercury)
- Mars: ~15 min (plus Mercury)
- Jupiter: ~8 min (plus Mercury)
- Saturn: ~5 min (plus Mars, Mercury)
- Uranus: ~10 min (plus Mercury)
- Neptune: ~12 min (plus Uranus, Mercury)
- Pluto: ~5 min (plus Mercury)

**Full System (~60 min)**

## Extensibility

### Adding New Planets

1. Create `planets/newplanet.sh`
2. Implement required functions
3. Add dependencies if needed
4. Test with `vibe install newplanet`
5. Document in `docs/PLANETS.md`

### Custom Planets Directory

Users can add custom planets in:
```
~/.vibe-palace/planets/
```

These are automatically discovered by the CLI.

## Future Enhancements

### Planned Features

1. **Configuration Profiles**: Work vs personal setups
2. **Plugin System**: Dynamic planet loading
3. **Progress Bars**: Visual installation progress
4. **Parallel Installs**: Install independent planets concurrently
5. **Version Pinning**: Pin specific tool versions
6. **Rollback Points**: Create restore points during install

### Architecture Evolution

The system is designed to evolve:
- Can migrate from bash to Go/Python if needed
- Plugin architecture for extensibility
- Registry for planet discovery
