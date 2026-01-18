# Vibe Palace Planets

Each planet in the Vibe Solar System is a self-contained installation module that follows a standardized interface. This document defines the planet specification that all planets must implement.

## Planet Interface Specification

Every planet script MUST implement the following functions:

### Required Functions

#### 1. `planet_metadata()`
**Purpose**: Return metadata about the planet
**Output**: JSON-formatted string with keys:
  - `name`: Planet name (e.g., "mercury")
  - `version`: Semver version (e.g., "1.0.0")
  - `description`: Human-readable description
  - `duration`: Estimated installation time (e.g., "5 min")

```bash
planet_metadata() {
    cat <<EOF
{
  "name": "mercury",
  "version": "1.0.0",
  "description": "Terminal foundation tools",
  "duration": "5 min"
}
EOF
}
```

#### 2. `planet_dependencies()`
**Purpose**: Declare dependencies on other planets
**Output**: Array of planet names (space-separated)
**Example**: `echo "mercury venus"`

```bash
planet_dependencies() {
    # Return empty string if no dependencies
    echo ""
    # OR
    echo "mercury"
}
```

#### 3. `planet_install()`
**Purpose**: Main installation logic
**Return**: 0 on success, 1 on failure
**Requirements**:
  - MUST be idempotent (safe to run multiple times)
  - MUST use `log`, `success`, `warn`, `error` from lib/core.sh
  - MUST check if tools already exist before installing
  - SHOULD use `step` to show progress

```bash
planet_install() {
    banner "🪐 MERCURY: Terminal Foundation"

    step "Installing starship prompt"
    if command_exists starship; then
        log "starship already installed"
    else
        # Installation logic here
        curl -sS https://starship.rs/install.sh | sh
        success "starship installed"
    fi

    # More installation steps...

    success "Mercury installation complete"
    return 0
}
```

#### 4. `planet_uninstall()`
**Purpose**: Clean up and remove planet components
**Return**: 0 on success, 1 on failure
**Requirements**:
  - Remove binaries
  - Remove config files (with backup)
  - Remove packages
  - Update state file

```bash
planet_uninstall() {
    banner "🪐 Uninstalling Mercury"

    step "Removing starship"
    if [[ -f "$HOME/.local/bin/starship" ]]; then
        rm -f "$HOME/.local/bin/starship"
        success "starship removed"
    fi

    # More cleanup steps...

    # Remove from state
    state_remove "mercury"

    success "Mercury uninstalled"
    return 0
}
```

#### 5. `planet_check_health()`
**Purpose**: Verify planet installation is working
**Return**: 0 if healthy, 1 if unhealthy
**Requirements**:
  - Check binaries exist in PATH
  - Verify config files exist and are valid
  - Test basic functionality
  - Print health status with `success` or `error`

```bash
planet_check_health() {
    local failed=0

    echo "Checking Mercury health..."

    if ! command_exists starship; then
        error "starship not found in PATH"
        ((failed++))
    else
        success "starship installed"
    fi

    if [[ ! -f "$HOME/.config/starship.toml" ]]; then
        error "starship.toml config missing"
        ((failed++))
    else
        success "starship.toml exists"
    fi

    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issues"
        return 1
    fi

    success "Mercury is healthy"
    return 0
}
```

#### 6. `planet_is_installed()`
**Purpose**: Check if planet is already installed (idempotency check)
**Return**: 0 if installed, 1 if not
**Requirements**:
  - Quick check, don't run full installation
  - Check key binaries/configs exist

```bash
planet_is_installed() {
    # Check critical components
    command_exists starship && \
        command_exists eza && \
        [[ -f "$HOME/.config/starship.toml" ]]
}
```

## Planet Template

Copy this template to create a new planet:

```bash
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: NAME
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Brief description of what this planet does
# Duration: X min
# Dependencies: (list dependent planets or "none")
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get planet script directory
PLANET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core libraries
source "$PLANET_DIR/../lib/core.sh"
source "$PLANET_DIR/../lib/state.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

planet_metadata() {
    cat <<EOF
{
  "name": "planetname",
  "version": "1.0.0",
  "description": "Brief description",
  "duration": "5 min"
}
EOF
}

planet_dependencies() {
    # Return space-separated list of dependencies, or empty string
    echo "mercury"
}

planet_install() {
    banner "🪐 PLANETNAME: Installation"

    # Pre-flight checks
    if planet_is_installed; then
        log "Planet already installed, skipping..."
        return 0
    fi

    # Installation steps
    step "Installing tools..."

    # Your installation logic here

    # Update state
    state_add "planetname" "1.0.0"

    success "Planetname installation complete"
    return 0
}

planet_uninstall() {
    banner "🪐 Uninstalling Planetname"

    # Your cleanup logic here

    # Remove from state
    state_remove "planetname"

    success "Planetname uninstalled"
    return 0
}

planet_check_health() {
    local failed=0

    echo "Checking Planetname health..."

    # Check critical components
    if ! command_exists some_tool; then
        error "some_tool not found"
        ((failed++))
    fi

    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issues"
        return 1
    fi

    success "Planetname is healthy"
    return 0
}

planet_is_installed() {
    # Quick check if planet is installed
    command_exists some_tool && \
        [[ -f "$HOME/.config/some_config" ]]
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

# If script is executed directly (not sourced), run the requested function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        metadata)       planet_metadata ;;
        dependencies)   planet_dependencies ;;
        install)        planet_install ;;
        uninstall)      planet_uninstall ;;
        health)         planet_check_health ;;
        is_installed)   planet_is_installed ;;
        *)
            echo "Usage: $0 {metadata|dependencies|install|uninstall|health|is_installed}"
            exit 1
            ;;
    esac
fi
```

## Best Practices

### 1. Idempotency
- EVERY operation must be safe to run multiple times
- Check if things exist before installing
- Never assume previous state

### 2. Error Handling
- Always use `set -euo pipefail`
- Check return codes of external commands
- Use `error()` and return 1 on failures

### 3. User Experience
- Use `banner` for major sections
- Use `step` for installation phases
- Use `success` for completed tasks
- Use `log` for informational messages
- Use `warn` for non-critical issues
- Use `error` for failures

### 4. State Management
- ALWAYS call `state_add` after successful install
- ALWAYS call `state_remove` after uninstall
- Track versions for future updates

### 5. Config Management
- Backup configs before overwriting
- Use consistent config locations
- Document config changes

### 6. Dependencies
- Declare ALL planet dependencies
- Don't declare external package dependencies (brew, apt, etc.)
- Let the orbit controller handle resolution

## Planet Naming Convention

- Lowercase names
- Solar system theme: mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto
- Single word, no hyphens or underscores

## Directory Structure

Planets should create configs in standard locations:
- Binaries: `$HOME/.local/bin/` or system via brew/apt
- Configs: `$HOME/.config/<tool>/`
- Data: `$HOME/.local/share/<tool>/`
- State: `$VIBE_DIR/planets/<planet>/`

## Testing Your Planet

Test all functions:
```bash
# Test metadata
./planets/yourplanet.sh metadata

# Test dependencies
./planets/yourplanet.sh dependencies

# Test install
./planets/yourplanet.sh install

# Test health check
./planets/yourplanet.sh health

# Test idempotency (run install twice)
./planets/yourplanet.sh install
./planets/yourplanet.sh install  # Should be safe

# Test uninstall
./planets/yourplanet.sh uninstall
```

## Validation

Run the planet validator to check compliance:
```bash
./scripts/validate-planet.sh planets/yourplanet.sh
```
