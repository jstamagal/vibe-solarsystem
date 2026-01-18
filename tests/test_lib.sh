#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Core Library Tests
# ═══════════════════════════════════════════════════════════════════════════════
# Test suite for lib/core.sh and lib/state.sh
# Run with: bash tests/test_lib.sh
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the libraries
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/state.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
test_start() {
    ((TESTS_RUN++))
    echo -e "\n${BLUE}[TEST $TESTS_RUN]${NC} $1"
}

test_pass() {
    ((TESTS_PASSED++))
    success "PASSED: $1"
}

test_fail() {
    ((TESTS_FAILED++))
    error "FAILED: $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CORE LIBRARY TESTS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${MAGENTA}${BOLD}"
echo "════════════════════════════════════════════════════════════════"
echo "  TESTING LIB/CORE.SH"
echo "════════════════════════════════════════════════════════════════${NC}"

# Test: OS Detection
test_start "OS Detection"
OS=$(get_os)
if [[ "$OS" == "linux" ]] || [[ "$OS" == "darwin" ]]; then
    test_pass "get_os() returns: $OS"
else
    test_fail "get_os() returned unexpected value: $OS"
fi

# Test: Architecture Detection
test_start "Architecture Detection"
ARCH=$(get_arch)
if [[ -n "$ARCH" ]]; then
    test_pass "get_arch() returns: $ARCH"
else
    test_fail "get_arch() returned empty value"
fi

# Test: Command Existence (should exist)
test_start "Command Exists (bash)"
if command_exists "bash"; then
    test_pass "command_exists() found bash"
else
    test_fail "command_exists() couldn't find bash"
fi

# Test: Command Existence (should not exist)
test_start "Command Not Exists (fake_command_12345)"
if ! command_exists "fake_command_12345"; then
    test_pass "command_exists() correctly returned false for fake command"
else
    test_fail "command_exists() incorrectly found fake command"
fi

# Test: Logging Functions
test_start "Logging Functions"
log "Test log message"
if [[ -f "$LOG_FILE" ]]; then
    test_pass "log() wrote to log file"
else
    test_fail "log() didn't create log file"
fi

# Test: Directory Creation
test_start "Ensure Directory"
TEST_DIR="/tmp/vibe_test_$$"
ensure_dir "$TEST_DIR"
if [[ -d "$TEST_DIR" ]]; then
    test_pass "ensure_dir() created directory"
    rm -rf "$TEST_DIR"
else
    test_fail "ensure_dir() didn't create directory"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT TESTS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "\n${MAGENTA}${BOLD}"
echo "════════════════════════════════════════════════════════════════"
echo "  TESTING LIB/STATE.SH"
echo "════════════════════════════════════════════════════════════════${NC}"

# Use test state file to avoid messing with real one
export STATE_FILE="/tmp/vibe_test_state_$$.json"
export VIBE_DIR="/tmp/vibe_test_dir_$$"

# Test: State Initialization
test_start "State Initialization"
state_init
if [[ -f "$STATE_FILE" ]]; then
    test_pass "state_init() created state file"
else
    test_fail "state_init() didn't create state file"
fi

# Test: State Validation
test_start "State Validation"
if state_validate; then
    test_pass "state_validate() passed"
else
    test_fail "state_validate() failed"
fi

# Test: Add Planet
test_start "Add Planet to State"
state_add "mercury" "1.0.0" "abc123"
if state_is_installed "mercury"; then
    test_pass "state_add() added mercury to state"
else
    test_fail "state_add() didn't add mercury to state"
fi

# Test: Check Is Installed (true)
test_start "Check Is Installed (true)"
if state_is_installed "mercury"; then
    test_pass "state_is_installed() correctly found mercury"
else
    test_fail "state_is_installed() didn't find mercury"
fi

# Test: Check Is Installed (false)
test_start "Check Is Installed (false)"
if ! state_is_installed "venus"; then
    test_pass "state_is_installed() correctly returned false for venus"
else
    test_fail "state_is_installed() incorrectly found venus"
fi

# Test: Get Planet Version
test_start "Get Planet Version"
VERSION=$(state_get_version "mercury")
if [[ "$VERSION" == "1.0.0" ]]; then
    test_pass "state_get_version() returned correct version"
else
    test_fail "state_get_version() returned: $VERSION (expected 1.0.0)"
fi

# Test: List Planets
test_start "List Planets"
PLANETS=$(state_list)
if echo "$PLANETS" | grep -q "mercury"; then
    test_pass "state_list() included mercury"
else
    test_fail "state_list() didn't include mercury"
fi

# Test: Count Planets
test_start "Count Planets"
COUNT=$(state_count)
if [[ "$COUNT" -ge 1 ]]; then
    test_pass "state_count() returned: $COUNT"
else
    test_fail "state_count() returned: $COUNT (expected >= 1)"
fi

# Test: Add Another Planet
test_start "Add Second Planet"
state_add "venus" "2.0.0" "def456"
COUNT=$(state_count)
if [[ "$COUNT" -eq 2 ]]; then
    test_pass "state_count() correctly shows 2 planets"
else
    test_fail "state_count() returned: $COUNT (expected 2)"
fi

# Test: Remove Planet
test_start "Remove Planet"
state_remove "mercury"
if ! state_is_installed "mercury"; then
    test_pass "state_remove() removed mercury"
else
    test_fail "state_remove() didn't remove mercury"
fi

# Test: Backup State
test_start "Backup State"
BACKUP_FILE=$(state_backup)
if [[ -f "$BACKUP_FILE" ]]; then
    test_pass "state_backup() created: $BACKUP_FILE"
    rm -f "$BACKUP_FILE"
else
    test_fail "state_backup() didn't create backup"
fi

# Cleanup
rm -rf "$STATE_FILE" "$VIBE_DIR"

# ═══════════════════════════════════════════════════════════════════════════════
# TEST SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "\n${MAGENTA}${BOLD}"
echo "════════════════════════════════════════════════════════════════"
echo "  TEST SUMMARY"
echo "════════════════════════════════════════════════════════════════${NC}"

echo -e "Tests Run:    ${BOLD}$TESTS_RUN${NC}"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}${BOLD}[✓] ALL TESTS PASSED!${NC}\n"
    exit 0
else
    echo -e "\n${RED}${BOLD}[✗] SOME TESTS FAILED${NC}\n"
    exit 1
fi
