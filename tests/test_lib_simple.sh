#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Simple Library Tests
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Testing Vibe Palace Libraries..."
echo "================================"

# Source the libraries (they have their own set -euo pipefail)
source "$PROJECT_ROOT/lib/core.sh" 2>/dev/null || true
source "$PROJECT_ROOT/lib/state.sh" 2>/dev/null || true

TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name ... "

    # Run test in subshell to avoid exit on error
    if (eval "$test_command") > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo ""
echo "CORE LIBRARY TESTS"
echo "------------------"

run_test "OS Detection" "get_os | grep -q 'linux\|darwin'"
run_test "Architecture Detection" "get_arch | grep -q 'amd64\|arm64\|x86_64'"
run_test "Command Exists (bash)" "command_exists bash"
run_test "Command Not Exists (fake)" "! command_exists fake_command_xyz123"
run_test "Directory Creation" "TEST_DIR=/tmp/vibe_test_\$\$ && mkdir -p \$TEST_DIR && [[ -d \$TEST_DIR ]] && rm -rf \$TEST_DIR"

echo ""
echo "STATE MANAGEMENT TESTS"
echo "----------------------"

# Use test state file
export STATE_FILE="/tmp/vibe_test_state_$$.json"
export VIBE_DIR="/tmp/vibe_test_dir_$$"

run_test "State Initialization" "state_init && [[ -f \$STATE_FILE ]]"
run_test "State Validation" "state_validate"
run_test "Add Planet" "state_add mercury 1.0.0 abc123"
run_test "Check Is Installed (true)" "state_is_installed mercury"
run_test "Check Is Installed (false)" "! state_is_installed venus"
run_test "Get Planet Version" '[[ $(state_get_version mercury) == "1.0.0" ]]'
run_test "List Planets" "state_list | grep -q mercury"
run_test "Count Planets" '[[ $(state_count) -ge 1 ]]'
run_test "Remove Planet" "state_remove mercury && ! state_is_installed mercury"
run_test "Backup State" "state_backup | grep -q vibe_test_state"

# Cleanup
rm -f "$STATE_FILE"
rm -rf "$VIBE_DIR"

echo ""
echo "================================"
echo "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "================================"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}${BOLD}[✓] ALL TESTS PASSED!${NC}\n"
    exit 0
else
    echo -e "\n${RED}${BOLD}[✗] SOME TESTS FAILED${NC}\n"
    exit 1
fi
