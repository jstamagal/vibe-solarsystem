# Contributing to Vibe Palace

Thank you for your interest in contributing to Vibe Palace! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Adding a New Planet](#adding-a-new-planet)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Guidelines](#documentation-guidelines)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- Linux or macOS system
- Bash 4.0+
- Git
- Basic familiarity with shell scripting

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/vibe-palace.git
   cd vibe-palace
   ```

3. Create a development branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. Run tests to ensure everything works:
   ```bash
   ./tests/quick_test.sh
   ```

### Development Environment

- Use the `vibe` command directly from the repo
- Create a test environment:
   ```bash
   ./vibe install mercury --dry-run  # Test without installing
   ```

## Development Workflow

1. **Check for existing issues**: Look at [GitHub Issues](https://github.com/your-username/vibe-palace/issues)
2. **Create an issue**: Discuss your plans before coding
3. **Branch naming**: Use descriptive names:
   - `feature/add-new-planet`
   - `fix/health-check-failure`
   - `docs/update-readme`
   - `test/add-integration-tests`

4. **Make changes**: Follow the style guidelines
5. **Test thoroughly**: Run all relevant tests
6. **Update documentation**: Keep docs in sync
7. **Submit PR**: Create a pull request with clear description

## Adding a New Planet

### 1. Planet Template

Create `planets/your-planet.sh`:

```bash
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: YourPlanet
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Brief description of what this planet does
# Duration: ~X min
# Dependencies: planet1, planet2
#
# Tools:
#   - Tool1: Description
#   - Tool2: Description
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

PLANET_NAME="yourplanet"
PLANET_VERSION="1.0.0"
PLANET_DESC="Brief one-line description"

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
    # List one dependency per line
    echo "mercury"
}

# planet_install: Main installation logic
planet_install() {
    step "Installing $PLANET_NAME..."

    # Check if already installed
    if planet_is_installed; then
        log "Already installed, skipping..."
        return 0
    fi

    # Detect OS
    local os
    os=$(detect_os)

    # Install tools based on OS
    case "$os" in
        linux)
            log "Installing on Linux..."
            # Linux installation logic
            ;;
        macos)
            log "Installing on macOS..."
            # macOS installation logic
            ;;
        *)
            error "Unsupported OS: $os"
            return 1
            ;;
    esac

    # Verify installation
    if ! planet_check_health 2>/dev/null; then
        error "Installation verification failed"
        return 1
    fi

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "$PLANET_NAME installed successfully!"
    return 0
}

# planet_uninstall: Remove the planet
planet_uninstall() {
    step "Uninstalling $PLANET_NAME..."

    # Remove binaries
    if command_exists tool-name; then
        log "Removing tool-name..."
        # Uninstall logic
    fi

    # Remove configurations
    if [[ -d ~/.config/yourplanet ]]; then
        log "Removing configurations..."
        # Backup or remove configs
    fi

    # Update state
    state_remove "$PLANET_NAME"

    success "$PLANET_NAME uninstalled!"
    return 0
}

# planet_check_health: Verify installation is healthy
planet_check_health() {
    step "Checking $PLANET_NAME health..."

    local failed=0

    # Check if binaries exist
    if ! command_exists tool-name; then
        error "tool-name not found in PATH"
        ((failed++))
    fi

    # Check configurations
    if [[ ! -f ~/.config/yourplanet/config ]]; then
        warn "Configuration file not found"
        ((failed++))
    fi

    # Check functionality
    if ! tool-name --version &>/dev/null; then
        error "tool-name not functioning correctly"
        ((failed++))
    fi

    if [[ $failed -eq 0 ]]; then
        success "$PLANET_NAME is healthy!"
        return 0
    else
        error "$PLANET_NAME has $failed health issue(s)"
        return 1
    fi
}

# planet_is_installed: Check if already installed
planet_is_installed() {
    # Check for key indicators of installation
    command_exists tool-name && \
    [[ -f ~/.config/yourplanet/config ]]
}
```

### 2. Planet Checklist

- [ ] Implement all required functions
- [ ] Add proper error handling
- [ ] Support both Linux and macOS
- [ ] Include health checks
- [ ] Make installation idempotent
- [ ] Test installation and uninstallation
- [ ] Add to dependency graph if needed
- [ ] Update documentation

### 3. Testing Your Planet

Create a test in `tests/test_planets.sh`:

```bash
@test "yourplanet: installs successfully" {
    run ./vibe install yourplanet
    assert_success
}

@test "yourplanet: is idempotent" {
    run ./vibe install yourplanet
    run ./vibe install yourplanet
    assert_success
}

@test "yourplanet: health check passes" {
    run bash -c "source planets/yourplanet.sh && planet_check_health"
    assert_success
}

@test "yourplanet: uninstalls cleanly" {
    run ./vibe uninstall yourplanet
    assert_success
}
```

### 4. Documentation

Update `docs/PLANETS.md`:

```markdown
## 🌍 YourPlanet: Description

**Description**: Detailed description
**Version**: 1.0.0
**Duration**: ~X minutes
**Dependencies**: List dependencies

### Tools Installed

1. **Tool1** - Description
2. **Tool2** - Description

### Installation

```bash
vibe install yourplanet
```

### Usage

```bash
tool-name --help
```
```

## Code Style Guidelines

### Shell Script Style

1. **Shebang**: Always use `#!/usr/bin/env bash`
2. **Strict mode**: Always use `set -euo pipefail`
3. **Comments**: Use sections dividers:
   ```bash
   # ═══════════════════════════════════════════════════════════════════════════════
   # SECTION TITLE
   # ═══════════════════════════════════════════════════════════════════════════════
   ```

4. **Function naming**: Use `snake_case`:
   ```bash
   planet_install() { ... }
   check_health() { ... }
   ```

5. **Variables**: Use `UPPER_CASE` for globals, `lower_case` for locals:
   ```bash
   PLANET_NAME="mercury"
   local planet_dir="$HOME/planets"
   ```

6. **Quoting**: Always quote variables:
   ```bash
   "$file"     # Good
   $file       # Bad
   ```

7. **Error handling**: Check command success:
   ```bash
   if ! command_exists tool; then
       error "tool not found"
       return 1
   fi
   ```

### Code Organization

1. **Header**: License and description
2. **Configuration**: Set script options
3. **Globals**: Define global variables
4. **Functions**: Group related functions
5. **Main**: Entry point (if applicable)

### Best Practices

1. **Use functions**: Don't write everything at the top level
2. **Keep functions short**: One purpose per function
3. **Document functions**: Add comments explaining purpose
4. **Use descriptive names**: Make code self-documenting
5. **Avoid magic numbers**: Use named constants
6. **Validate inputs**: Check function arguments

### Error Messages

- Be specific: `error "Failed to download tool-name"`
- Include next steps: `error "Run 'vibe doctor' for help"`
- Use consistent formatting: Start with lowercase
- Provide context: Include what was being attempted

## Testing Guidelines

### Test Structure

Tests are in the `tests/` directory:

- `test_lib.sh` - Core library tests
- `test_planets.sh` - Planet-specific tests
- `test_deps.sh` - Dependency resolution tests
- `integration.sh` - Full system tests
- `quick_test.sh` - Fast smoke tests

### Writing Tests

1. **Use descriptive test names**:
   ```bash
   @test "mercury: installs starship prompt" {
       # ...
   }
   ```

2. **Test both success and failure**:
   ```bash
   @test "fails when tool not found" {
       run some_command
       assert_failure
   }
   ```

3. **Clean up after tests**:
   ```bash
   setup() {
       # Setup test environment
   }

   teardown() {
       # Clean up
       rm -rf /tmp/test-files
   }
   ```

4. **Use assertions**:
   ```bash
   assert_success      # Command succeeded
   assert_failure      # Command failed
   assert_output "foo" # Output contains "foo"
   assert_line 0 "bar" # Line 0 is "bar"
   ```

### Running Tests

```bash
# Quick smoke tests
./tests/quick_test.sh

# All tests
bats tests/

# Specific test file
bats tests/test_lib.sh

# Verbose output
bats -t tests/

# With filter
bats -f "mercury" tests/
```

### Test Coverage

- Aim for >80% code coverage
- Test all planet functions
- Test error conditions
- Test idempotency
- Test rollback

## Documentation Guidelines

### Documentation Files

- `README.md` - Main project documentation
- `docs/ARCHITECTURE.md` - System architecture
- `docs/PLANETS.md` - Planet descriptions
- `docs/CONTRIBUTING.md` - This file
- `docs/BACKUP_RESTORE.md` - Backup/restore guide
- `docs/TESTING.md` - Testing guide

### Writing Documentation

1. **Use clear, simple language**
2. **Include examples for every feature**
3. **Keep documentation up to date**
4. **Use code blocks for commands**:
   ```bash
   vibe install mercury
   ```
5. **Add troubleshooting sections**
6. **Include diagrams where helpful**

### Code Comments

- **DO** comment "why" not "what"
- **DON'T** comment obvious code
- **DO** document workarounds
- **DO** add TODO markers for future work

Example:
```bash
# Good: Explains why
# Use /bin/bash explicitly for macOS compatibility
SHELL="/bin/bash"

# Bad: States the obvious
# Set SHELL variable
SHELL="/bin/bash"
```

## Submitting Changes

### Pull Request Process

1. **Update your branch**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**:
   ```bash
   ./tests/quick_test.sh
   ```

3. **Create PR**:
   - Use clear title: "Add Saturn planet for AI tools"
   - Describe changes: What, why, how
   - Link issues: "Fixes #123"
   - Add screenshots if applicable

4. **PR Checklist**:
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] Code follows style guide
   - [ ] Commit messages are clear
   - [ ] No merge conflicts

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `chore`: Maintenance

Examples:
```
feat(venus): add Neovim 0.11+ support

Update LazyVim to work with Neovim 0.11
breaking change: Requires Neovim 0.11 or higher

fix(mercury): handle missing starship config

Don't fail if starship.toml doesn't exist

docs(planets): update Jupiter installation instructions

Add PostgreSQL client setup steps

test(deps): add circular dependency detection

Ensure we catch circular deps before installation
```

### Code Review Guidelines

**For Reviewers:**
- Be constructive and respectful
- Explain reasoning for suggestions
- Approve if changes are good enough (not perfect)
- Test changes if possible

**For Authors:**
- Address review feedback
- Ask for clarification if needed
- Update PR rather than force push
- Mark conversations as resolved

## Review Process

1. **Automated checks**: CI runs tests
2. **Manual review**: Maintainer reviews code
3. **Feedback**: Request changes if needed
4. **Approval**: Maintainer approves
5. **Merge**: Squash and merge to main
6. **Release**: Included in next release

### Getting Feedback Faster

- Keep PRs small and focused
- Write clear descriptions
- Respond to comments promptly
- Update based on feedback
- Be patient with review process

## Questions?

- Open an issue on GitHub
- Start a discussion
- Check existing documentation

Thank you for contributing to Vibe Palace! 🚀
