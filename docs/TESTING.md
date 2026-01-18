# Testing Guide

This guide covers testing Vibe Palace components, from unit tests to full system integration.

## Overview

Vibe Palace uses a comprehensive testing approach:

- **Unit Tests**: Test individual functions
- **Integration Tests**: Test planet installation/uninstallation
- **Health Checks**: Verify system health
- **Smoke Tests**: Quick validation

## Test Structure

```
tests/
├── test_lib.sh           # Core library tests
├── test_lib_simple.sh    # Simple lib tests (fast)
├── test_planets.sh       # Planet-specific tests
├── test_deps.sh          # Dependency resolution tests
├── integration.sh        # Full system tests
└── quick_test.sh         # Fast smoke tests
```

## Prerequisites

### Install Bats (Bash Automated Testing System)

```bash
# On macOS
brew install bats-core

# On Linux
# Check if bats is available
bats --version

# If not available, install:
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Verify Test Environment

```bash
cd /path/to/vibe-palace
./tests/quick_test.sh
```

Should run without errors.

## Running Tests

### Quick Smoke Tests

Fast validation of core functionality:

```bash
./tests/quick_test.sh
```

Tests:
- ✅ Core library functions
- ✅ State management
- ✅ Dependency resolution
- ✅ Basic planet loading

**Duration**: ~30 seconds

### Run All Tests

Complete test suite:

```bash
# Run all tests
bats tests/

# With verbose output
bats -t tests/

# With timing information
bats --timing tests/

# Stop on first failure
bats --fail-fast tests/
```

**Duration**: ~2-5 minutes

### Run Specific Test File

```bash
# Test core library
bats tests/test_lib.sh

# Test planets
bats tests/test_planets.sh

# Test dependencies
bats tests/test_deps.sh

# Integration tests
bats tests/integration.sh
```

### Run Specific Tests by Name

```bash
# Run tests matching pattern
bats -f "mercury" tests/

# Run tests matching pattern (case insensitive)
bats -f "state" tests/
```

## Test Files

### test_lib.sh

Tests core library functions in `lib/`.

**Test categories:**

1. **Logging Functions**
   ```bash
   @test "log: outputs message"
   @test "success: outputs success message"
   @test "error: outputs error message"
   ```

2. **State Management**
   ```bash
   @test "state_init: creates state directory"
   @test "state_add: adds planet to state"
   @test "state_remove: removes planet from state"
   @test "state_is_installed: checks installation"
   ```

3. **OS Detection**
   ```bash
   @test "detect_os: detects Linux"
   @test "detect_os: detects macOS"
   ```

4. **Command Existence**
   ```bash
   @test "command_exists: returns 0 if command exists"
   @test "command_exists: returns 1 if command not found"
   ```

### test_lib_simple.sh

Simplified, fast tests for core functions.

**Purpose:** Quick validation without heavy setup.

**Tests:**
- Core library loading
- Basic state operations
- Simple dependency checks

### test_planets.sh

Tests for individual planets.

**Test template:**

```bash
@test "mercury: installs successfully" {
    run ./vibe install mercury --yes
    assert_success
    assert_output --partial "mercury installed successfully"
}

@test "mercury: is idempotent" {
    run ./vibe install mercury --yes
    run ./vibe install mercury --yes
    assert_success
}

@test "mercury: health check passes" {
    run bash -c "source planets/mercury.sh && planet_check_health"
    assert_success
}

@test "mercury: uninstalls cleanly" {
    run ./vibe uninstall mercury --yes
    assert_success
    assert_output --partial "uninstalled"
}
```

**Test categories:**

1. **Installation**
   - Successful installation
   - Idempotency (run twice)
   - Dependency resolution
   - Error handling

2. **Health Checks**
   - Binary existence
   - Config file checks
   - Functionality tests

3. **Uninstallation**
   - Clean removal
   - State updates
   - No leftover files

### test_deps.sh

Tests for dependency resolution.

**Tests:**

```bash
@test "deps_get: returns dependencies" {
    run deps_get "venus"
    assert_output "mercury"
}

@test "deps_sort_topological: orders correctly" {
    run deps_sort_topological "saturn"
    assert_line --index 0 "mercury"
    assert_line --index 1 "mars"
    assert_line --index 2 "saturn"
}

@test "deps_detect_circular: catches circular deps" {
    # Test if circular deps are detected
    run deps_validate
    assert_success
}
```

### integration.sh

Full system integration tests.

**Tests:**

```bash
@test "full install: installs all planets" {
    run ./vibe install --all --yes
    assert_success
}

@test "full install: creates correct state" {
    run ./vibe status
    assert_line --partial "8 planet(s)"
}

@test "doctor: all systems healthy" {
    run ./vibe doctor
    assert_success
    assert_output --partial "All systems operational"
}
```

## Writing Tests

### Basic Test Structure

```bash
#!/usr/bin/env bats
# File: tests/test_example.sh

setup() {
    # Setup before each test
    export TEST_DIR="/tmp/vibe-test-$RANDOM"
    mkdir -p "$TEST_DIR"
}

teardown() {
    # Cleanup after each test
    rm -rf "$TEST_DIR"
}

@test "example: basic test" {
    # Arrange
    local expected="hello"

    # Act
    run echo "hello"

    # Assert
    assert_success
    assert_output "$expected"
}

@test "example: test failure case" {
    run command_that_fails
    assert_failure
    assert_output --partial "error message"
}
```

### Testing Planet Installation

```bash
@test "myplanet: installs successfully" {
    # Run installation
    run ./vibe install myplanet --yes

    # Check success
    assert_success

    # Check output
    assert_output --partial "myplanet installed"

    # Verify state
    run state_is_installed "myplanet"
    assert_success
}

@test "myplanet: installs dependencies first" {
    run ./vibe install myplanet --yes

    # Check dependency was installed
    run state_is_installed "dependency-planet"
    assert_success
}
```

### Testing Health Checks

```bash
@test "myplanet: health check passes" {
    # Source planet and run health check
    run bash -c "source planets/myplanet.sh && planet_check_health"

    assert_success
    assert_output --partial "healthy"
}

@test "myplanet: health check fails without install" {
    # Should fail if not installed
    run bash -c "source planets/myplanet.sh && planet_check_health"

    assert_failure
}
```

### Testing Idempotency

```bash
@test "myplanet: running twice is safe" {
    # First install
    run ./vibe install myplanet --yes
    assert_success

    # Second install (should skip)
    run ./vibe install myplanet --yes
    assert_success
    assert_output --partial "Already installed"
}
```

### Testing Uninstallation

```bash
@test "myplanet: uninstall removes planet" {
    # Install first
    ./vibe install myplanet --yes

    # Uninstall
    run ./vibe uninstall myplanet --yes
    assert_success

    # Check removed from state
    run state_is_installed "myplanet"
    assert_failure
}

@test "myplanet: uninstall removes files" {
    ./vibe install myplanet --yes

    ./vibe uninstall myplanet --yes

    # Check files removed
    refute [ -f "/path/to/config" ]
}
```

## Assertions

### Common Assertions

```bash
# Success/Failure
assert_success          # Command succeeded (exit code 0)
assert_failure          # Command failed (non-zero exit code)

# Output assertions
assert_output "text"    # Output equals "text"
assert_output --partial "substring"  # Output contains "substring"
assert_line 0 "line"    # Line 0 equals "line"
assert_line --index 1 --partial "text"  # Line 1 contains "text"

# Refutations
refute_success          # Command did not succeed
refute_output "text"    # Output does not equal "text"
refute [ -f file ]      # File does not exist

# Equality
[ "$output" = "text" ]  # Compare strings
[ $status -eq 0 ]       # Compare exit codes
```

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]

    steps:
    - uses: actions/checkout@v3

    - name: Install Bats
      run: |
        if [[ "$RUNNER_OS" == "macOS" ]]; then
          brew install bats-core
        else
          git clone https://github.com/bats-core/bats-core.git
          cd bats-core
          sudo ./install.sh /usr/local
        fi

    - name: Run tests
      run: bats tests/

    - name: Run integration tests
      run: bats tests/integration.sh
```

### Local Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
# Run tests before committing

echo "Running tests..."
bats tests/

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "Tests passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Test Coverage

### Measuring Coverage

Install `bashcov`:
```bash
gem install bashcov
```

Run tests with coverage:
```bash
bashcov -- bats tests/
```

### Coverage Goals

- **Core Library**: 90%+ coverage
- **Planets**: 80%+ coverage
- **CLI**: 85%+ coverage

### Coverage Reports

Generate HTML coverage report:
```bash
bashcov --html bats tests/
open coverage/index.html
```

## Troubleshooting

### Tests Fail Locally

**Problem**: Tests pass in CI but fail locally.

**Solutions:**
1. Check for environment differences:
   ```bash
   uname -a
   bash --version
   bats --version
   ```

2. Clean test artifacts:
   ```bash
   rm -rf /tmp/vibe-test-*
   rm -rf ~/.vibe-palace/state.json
   ```

3. Check for leftover processes:
   ```bash
   ps aux | grep vibe
   ```

### Flaky Tests

**Problem**: Tests sometimes pass, sometimes fail.

**Causes:**
- Network dependencies
- Race conditions
- Filesystem timing
- Random data

**Solutions:**
1. Add retries:
   ```bash
   retry=3
   while [ $retry -gt 0 ]; do
       run some_command
       assert_success && break
       ((retry--))
       sleep 1
   done
   ```

2. Mock external dependencies:
   ```bash
   # Mock network calls
   mock_curl() { echo "mocked"; }
   curl() { mock_curl; }
   ```

3. Use fixtures:
   ```bash
   # Use pre-downloaded files
   export FIXTURE_DIR="tests/fixtures"
   ```

### Slow Tests

**Problem**: Tests take too long.

**Solutions:**
1. Use `--parallel` flag:
   ```bash
   bats --parallel tests/
   ```

2. Skip slow tests:
   ```bash
   @test "slow: expensive test" {
       skip "Skipping slow test in CI"
       # ... test code
   }
   ```

3. Use test markers:
   ```bash
   @test "unit: fast test" {
       # Fast unit test
   }

   @test "integration: slow test" {
       # Slow integration test
   }
   ```

   Then run only unit tests:
   ```bash
   bats -f "unit" tests/
   ```

## Best Practices

### Test Organization

1. **One test file per module**: `test_mercury.sh`, `test_venus.sh`
2. **Group related tests**: Use descriptive prefixes
3. **Keep tests independent**: Each test should work alone
4. **Use setup/teardown**: For common test code

### Test Naming

Use descriptive names:
```bash
# Good
@test "mercury: installs starship prompt"

# Bad
@test "install test"
```

### Test Isolation

Each test should:
- Clean up after itself
- Not depend on other tests
- Work in isolation
- Use temporary directories

### Mocking

Mock external dependencies:
```bash
# Mock network calls
curl() {
    echo "{\"status\": \"ok\"}"
}

# Mock system commands
hostname() {
    echo "test-host"
}

# Mock file system
export TEST_TMP=$(mktemp -d)
cd "$TEST_TMP"
```

## Continuous Improvement

### Adding Tests

When adding new features:
1. Write tests first (TDD)
2. Implement feature
3. Verify tests pass
4. Add to CI/CD

### Updating Tests

When modifying code:
1. Update tests to match
2. Add tests for new behavior
3. Remove obsolete tests
4. Update documentation

### Test Metrics

Track:
- Test count: `bats --count tests/`
- Test duration: `bats --timing tests/`
- Pass rate: CI statistics
- Coverage: `bashcov` reports

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guide
- [Bats Documentation](https://bats-core.readthedocs.io/) - Bats testing framework
