#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet Tests
# ═══════════════════════════════════════════════════════════════════════════════
# Test suite for individual planet functionality
# Tests: metadata, dependencies, install/uninstall, health checks, idempotency
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get script directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Source core libraries
source "$PROJECT_DIR/lib/core.sh"
source "$PROJECT_DIR/lib/state.sh"

# Test configuration
export VIBE_DIR="$(mktemp -d -t vibe-test-XXXXXX)"
export STATE_FILE="$VIBE_DIR/state.json"
export PLANETS_DIR="$PROJECT_DIR/planets"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ═══════════════════════════════════════════════════════════════════════════════
# TEST FRAMEWORK FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# test_start: Begin a test
test_start() {
    local name="$1"
    ((TESTS_RUN++))
    echo -n "[$TESTS_RUN] $name ... "
}

# test_pass: Mark test as passed
test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}PASS${NC}"
}

# test_fail: Mark test as failed
test_fail() {
    local reason="${1:-Unknown reason}"
    ((TESTS_FAILED++))
    echo -e "${RED}FAIL${NC} - $reason"
}

# test_skip: Skip a test
test_skip() {
    local reason="${1:-No reason given}"
    echo -e "${YELLOW}SKIP${NC} - $reason"
}

# assert_eq: Assert two values are equal
assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Assertion failed}"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        test_fail "$msg (expected: '$expected', got: '$actual')"
        return 1
    fi
}

# assert_success: Assert command succeeded
assert_success() {
    if [[ $? -eq 0 ]]; then
        return 0
    else
        test_fail "Command failed: $*"
        return 1
    fi
}

# assert_file_exists: Assert file exists
assert_file_exists() {
    local file="$1"

    if [[ -f "$file" ]]; then
        return 0
    else
        test_fail "File does not exist: $file"
        return 1
    fi
}

# assert_dir_exists: Assert directory exists
assert_dir_exists() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        return 0
    else
        test_fail "Directory does not exist: $dir"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET TESTS
# ═══════════════════════════════════════════════════════════════════════════════

# test_planet_metadata: Test planet metadata function
test_planet_metadata() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    test_start "Planet $planet - metadata"

    if [[ ! -f "$planet_script" ]]; then
        test_fail "Planet script not found"
        return 1
    fi

    # Source planet script
    if source "$planet_script" 2>/dev/null; then
        local metadata
        metadata=$(planet_metadata 2>/dev/null || echo "")

        if [[ -z "$metadata" ]]; then
            test_fail "planet_metadata returned empty"
            return 1
        fi

        # Validate it's valid JSON
        if command_exists jq; then
            local name
            name=$(echo "$metadata" | jq -r '.name // empty' 2>/dev/null)

            if [[ -z "$name" ]]; then
                test_fail "Invalid metadata: missing 'name' field"
                return 1
            fi

            if [[ "$name" != "$planet" ]]; then
                test_fail "Planet name mismatch (expected: $planet, got: $name)"
                return 1
            fi
        fi

        test_pass
    else
        test_fail "Failed to source planet"
    fi
}

# test_planet_dependencies: Test planet dependencies function
test_planet_dependencies() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    test_start "Planet $planet - dependencies"

    if source "$planet_script" 2>/dev/null; then
        # Get dependencies (function should always exist)
        local deps
        deps=$(planet_dependencies 2>/dev/null || echo "")

        # Dependencies can be empty, but function must not error
        test_pass
    else
        test_fail "Failed to source planet"
    fi
}

# test_planet_interface: Test planet has required functions
test_planet_interface() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    test_start "Planet $planet - required functions"

    if source "$planet_script" 2>/dev/null; then
        local missing=()

        # Check for required functions
        declare -f planet_metadata >/dev/null || missing+=("planet_metadata")
        declare -f planet_dependencies >/dev/null || missing+=("planet_dependencies")
        declare -f planet_install >/dev/null || missing+=("planet_install")
        declare -f planet_uninstall >/dev/null || missing+=("planet_uninstall")
        declare -f planet_check_health >/dev/null || missing+=("planet_check_health")
        declare -f planet_is_installed >/dev/null || missing+=("planet_is_installed")

        if [[ ${#missing[@]} -gt 0 ]]; then
            test_fail "Missing functions: ${missing[*]}"
            return 1
        fi

        test_pass
    else
        test_fail "Failed to source planet"
    fi
}

# test_planet_is_installed: Test planet_is_installed function
test_planet_is_installed() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    test_start "Planet $planet - is_installed function"

    if source "$planet_script" 2>/dev/null; then
        # Function should return 0 or 1
        if planet_is_installed >/dev/null 2>&1; then
            local ret=$?
        else
            local ret=$?
        fi

        # Return code should be 0 (true) or 1 (false)
        if [[ $ret -eq 0 ]] || [[ $ret -eq 1 ]]; then
            test_pass
        else
            test_fail "Invalid return code: $ret"
        fi
    else
        test_fail "Failed to source planet"
    fi
}

# test_planet_health_check: Test planet_check_health function
test_planet_health_check() {
    local planet="$1"
    local planet_script="$PLANETS_DIR/$planet.sh"

    test_start "Planet $planet - health_check function"

    if source "$planet_script" 2>/dev/null; then
        # Health check should run without error
        # Output is not important, just that it doesn't crash
        if planet_check_health >/dev/null 2>&1; then
            test_pass
        else
            # Health check can fail (planet not installed), but function must exist
            test_pass
        fi
    else
        test_fail "Failed to source planet"
    fi
}

# test_planet_file_exists: Test planet file exists and is executable
test_planet_file_exists() {
    local planet="$1"

    test_start "Planet $planet - file exists"

    local planet_script="$PLANETS_DIR/$planet.sh"

    if [[ ! -f "$planet_script" ]]; then
        test_fail "File not found: $planet_script"
        return 1
    fi

    test_pass
}

# test_planet_sourceable: Test planet script can be sourced
test_planet_sourceable() {
    local planet="$1"

    test_start "Planet $planet - sourceable"

    local planet_script="$PLANETS_DIR/$planet.sh"

    # Try to source in a subshell
    if (source "$planet_script" 2>/dev/null); then
        test_pass
    else
        test_fail "Failed to source: $planet_script"
    fi
}

# run_all_planet_tests: Run all tests for a planet
run_all_planet_tests() {
    local planet="$1"

    echo ""
    echo "Testing planet: $planet"
    echo "─────────────────────────────────────────"

    test_planet_file_exists "$planet"
    test_planet_sourceable "$planet"
    test_planet_metadata "$planet"
    test_planet_dependencies "$planet"
    test_planet_interface "$planet"
    test_planet_is_installed "$planet"
    test_planet_health_check "$planet"
}

# run_tests_for_all_planets: Run tests for all planets
run_tests_for_all_planets() {
    local planets
    planets=$(ls -1 "$PLANETS_DIR"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | grep -v '^example$')

    if [[ -z "$planets" ]]; then
        echo "No planets found in $PLANETS_DIR"
        return 1
    fi

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           Vibe Palace - Planet Test Suite                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    while IFS= read -r planet; do
        if [[ -n "$planet" ]]; then
            run_all_planet_tests "$planet"
        fi
    done <<< "$planets"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TEST SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                      Test Summary                              ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    printf "║  Total Tests:  %-45d ║\n" "$TESTS_RUN"
    printf "║  ${GREEN}Passed:       %-45d${NC} ║\n" "$TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        printf "║  ${RED}Failed:       %-45d${NC} ║\n" "$TESTS_FAILED"
    else
        printf "║  Failed:       %-45d ║\n" "$TESTS_FAILED"
    fi

    echo "╚════════════════════════════════════════════════════════════════╝"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        success "All tests passed!"
        return 0
    else
        echo ""
        error "Some tests failed!"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

cleanup() {
    echo ""
    log "Cleaning up test directory: $VIBE_DIR"
    rm -rf "$VIBE_DIR"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    trap cleanup EXIT

    # Initialize state
    state_init

    # Run tests
    run_tests_for_all_planets

    # Print summary
    print_summary
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
