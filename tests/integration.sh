#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Integration Tests
# ═══════════════════════════════════════════════════════════════════════════════
# Full system integration tests
# Tests: complete workflows, multi-planet scenarios, error recovery, backup/restore
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get script directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Source core libraries
source "$PROJECT_DIR/lib/core.sh"
source "$PROJECT_DIR/lib/state.sh"
source "$PROJECT_DIR/lib/backup.sh"

# Vibe command
VIBE_CMD="$PROJECT_DIR/vibe"

# Test configuration
export VIBE_DIR="$(mktemp -d -t vibe-integration-XXXXXX)"
export STATE_FILE="$VIBE_DIR/state.json"
export BACKUP_DIR="$VIBE_DIR/backups"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ═══════════════════════════════════════════════════════════════════════════════
# TEST FRAMEWORK
# ═══════════════════════════════════════════════════════════════════════════════

test_start() {
    local name="$1"
    ((TESTS_RUN++))
    echo -n "[$TESTS_RUN] $name ... "
}

test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}PASS${NC}"
}

test_fail() {
    local reason="${1:-Unknown reason}"
    ((TESTS_FAILED++))
    echo -e "${RED}FAIL${NC} - $reason"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_state_init() {
    test_start "state initialization"

    state_init

    if [[ ! -f "$STATE_FILE" ]]; then
        test_fail "State file not created"
        return 1
    fi

    test_pass
}

test_state_add_planet() {
    test_start "state_add - add planet"

    state_init

    if state_add "test_planet" "1.0.0" "abc123" 2>/dev/null; then
        if state_is_installed "test_planet"; then
            test_pass
        else
            test_fail "Planet not marked as installed"
        fi
    else
        test_fail "Failed to add planet"
    fi
}

test_state_remove_planet() {
    test_start "state_remove - remove planet"

    state_init
    state_add "test_planet" "1.0.0" "abc123" 2>/dev/null

    if state_remove "test_planet" 2>/dev/null; then
        if state_is_installed "test_planet"; then
            test_fail "Planet still marked as installed"
            return 1
        fi
        test_pass
    else
        test_fail "Failed to remove planet"
    fi
}

test_state_validate() {
    test_start "state_validate - validate state file"

    state_init
    state_add "mercury" "1.0.0" "abc123" 2>/dev/null

    if state_validate 2>/dev/null; then
        test_pass
    else
        test_fail "State validation failed"
    fi
}

test_state_export_import() {
    test_start "state_export/import - round trip"

    state_init
    state_add "test_planet" "1.0.0" "abc123" 2>/dev/null

    local exported
    exported=$(state_export 2>/dev/null)

    if [[ -z "$exported" ]]; then
        test_fail "Export returned empty"
        return 1
    fi

    # Clear state
    rm -f "$STATE_FILE"

    # Import
    if state_import "$exported" 2>/dev/null; then
        if state_is_installed "test_planet"; then
            test_pass
        else
            test_fail "Imported state not correct"
        fi
    else
        test_fail "Import failed"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP & RESTORE TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_backup_create() {
    test_start "backup_create - create backup"

    state_init
    state_add "mercury" "1.0.0" "abc123" 2>/dev/null

    local backup_file
    backup_file=$(backup_create 2>/dev/null)

    if [[ -z "$backup_file" ]]; then
        test_fail "No backup file returned"
        return 1
    fi

    if [[ ! -f "$backup_file" ]]; then
        test_fail "Backup file not created: $backup_file"
        return 1
    fi

    test_pass
}

test_backup_validate() {
    test_start "backup_validate - validate backup"

    state_init
    state_add "mercury" "1.0.0" "abc123" 2>/dev/null

    local backup_file
    backup_file=$(backup_create 2>/dev/null)

    if backup_validate "$backup_file" 2>/dev/null; then
        test_pass
    else
        test_fail "Backup validation failed"
    fi
}

test_backup_configs_only() {
    test_start "backup_configs_only - configs without state"

    local backup_file
    backup_file=$(backup_configs_only 2>/dev/null)

    if [[ -z "$backup_file" ]]; then
        test_fail "No backup file returned"
        return 1
    fi

    if [[ ! -f "$backup_file" ]]; then
        test_fail "Backup file not created: $backup_file"
        return 1
    fi

    test_pass
}

test_backup_restore() {
    test_start "backup_restore - restore from backup"

    # Create backup
    state_init
    state_add "mercury" "1.0.0" "abc123" 2>/dev/null
    state_add "venus" "1.0.0" "def456" 2>/dev/null

    local backup_file
    backup_file=$(backup_create 2>/dev/null)

    # Clear state
    rm -f "$STATE_FILE"

    # Restore
    if backup_restore "$backup_file" "false" 2>/dev/null; then
        # Check state was restored
        if state_is_installed "mercury" && state_is_installed "venus"; then
            test_pass
        else
            test_fail "State not restored correctly"
        fi
    else
        test_fail "Restore failed"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET INTERFACE TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_planet_all_have_metadata() {
    test_start "all planets have metadata"

    local failed=0
    local planet_script

    while IFS= read -r planet; do
        if [[ -z "$planet" ]]; then
            continue
        fi

        planet_script="$PROJECT_DIR/planets/$planet.sh"

        if source "$planet_script" 2>/dev/null; then
            local metadata
            metadata=$(planet_metadata 2>/dev/null || echo "")

            if [[ -z "$metadata" ]]; then
                error "$planet: No metadata"
                ((failed++))
            fi
        else
            error "$planet: Failed to source"
            ((failed++))
        fi
    done < <(ls -1 "$PROJECT_DIR/planets"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | grep -v '^example$')

    if [[ $failed -eq 0 ]]; then
        test_pass
    else
        test_fail "$failed planet(s) failed metadata check"
    fi
}

test_planet_all_have_dependencies() {
    test_start "all planets have dependencies function"

    local failed=0

    while IFS= read -r planet; do
        if [[ -z "$planet" ]]; then
            continue
        fi

        planet_script="$PROJECT_DIR/planets/$planet.sh"

        if source "$planet_script" 2>/dev/null; then
            if ! declare -f planet_dependencies >/dev/null; then
                error "$planet: Missing dependencies function"
                ((failed++))
            fi
        fi
    done < <(ls -1 "$PROJECT_DIR/planets"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | grep -v '^example$')

    if [[ $failed -eq 0 ]]; then
        test_pass
    else
        test_fail "$failed planet(s) missing dependencies function"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# IDEMPOTENCY TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_state_add_idempotent() {
    test_start "state_add is idempotent"

    state_init

    # Add same planet twice
    state_add "test_planet" "1.0.0" "abc123" 2>/dev/null
    state_add "test_planet" "1.0.0" "abc123" 2>/dev/null

    # Should still be installed
    if state_is_installed "test_planet"; then
        # Count should be 1
        local count
        count=$(state_count 2>/dev/null || echo "0")

        if [[ "$count" == "1" ]]; then
            test_pass
        else
            test_fail "State not idempotent (count: $count)"
        fi
    else
        test_fail "Planet not installed after add"
    fi
}

test_state_remove_idempotent() {
    test_start "state_remove is idempotent"

    state_init
    state_add "test_planet" "1.0.0" "abc123" 2>/dev/null

    # Remove twice
    state_remove "test_planet" 2>/dev/null
    state_remove "test_planet" 2>/dev/null

    if ! state_is_installed "test_planet"; then
        test_pass
    else
        test_fail "Planet still installed after remove"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ERROR HANDLING TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_state_invalid_json() {
    test_start "state_validate rejects invalid JSON"

    echo "{invalid json}" > "$STATE_FILE"

    if state_validate 2>/dev/null; then
        test_fail "Should reject invalid JSON"
        return 1
    fi

    test_pass
}

test_backup_nonexistent_file() {
    test_start "backup_validate handles missing file"

    if backup_validate "/nonexistent/backup.tar.gz" 2>/dev/null; then
        test_fail "Should fail on missing file"
        return 1
    fi

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_full_backup_restore_workflow() {
    test_start "full backup -> restore workflow"

    # Setup: create state with multiple planets
    state_init
    state_add "mercury" "1.0.0" "abc123" 2>/dev/null
    state_add "venus" "1.0.0" "def456" 2>/dev/null
    state_add "mars" "1.0.0" "ghi789" 2>/dev/null

    # Backup
    local backup_file
    backup_file=$(backup_create 2>/dev/null)

    if [[ ! -f "$backup_file" ]]; then
        test_fail "Backup not created"
        return 1
    fi

    # Validate backup
    if ! backup_validate "$backup_file" 2>/dev/null; then
        test_fail "Backup validation failed"
        return 1
    fi

    # Clear state
    rm -f "$STATE_FILE"

    # Restore
    if ! backup_restore "$backup_file" 2>/dev/null; then
        test_fail "Restore failed"
        return 1
    fi

    # Verify all planets restored
    if state_is_installed "mercury" && \
       state_is_installed "venus" && \
       state_is_installed "mars"; then
        test_pass
    else
        test_fail "Not all planets restored"
    fi
}

test_configs_only_workflow() {
    test_start "configs-only backup workflow"

    # Create configs backup
    local backup_file
    backup_file=$(backup_configs_only 2>/dev/null)

    if [[ ! -f "$backup_file" ]]; then
        test_fail "Configs backup not created"
        return 1
    fi

    # Validate
    if ! backup_validate "$backup_file" 2>/dev/null; then
        test_fail "Configs backup validation failed"
        return 1
    fi

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# TEST SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  Integration Test Summary                     ║"
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
        success "All integration tests passed!"
        return 0
    else
        echo ""
        error "Some integration tests failed!"
        return 1
    fi
}

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

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              Vibe Palace - Integration Test Suite             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "State Management Tests"
    echo "─────────────────────────────────────────"
    test_state_init
    test_state_add_planet
    test_state_remove_planet
    test_state_validate
    test_state_export_import

    echo ""
    echo "Backup & Restore Tests"
    echo "─────────────────────────────────────────"
    test_backup_create
    test_backup_validate
    test_backup_configs_only
    test_backup_restore

    echo ""
    echo "Planet Interface Tests"
    echo "─────────────────────────────────────────"
    test_planet_all_have_metadata
    test_planet_all_have_dependencies

    echo ""
    echo "Idempotency Tests"
    echo "─────────────────────────────────────────"
    test_state_add_idempotent
    test_state_remove_idempotent

    echo ""
    echo "Error Handling Tests"
    echo "─────────────────────────────────────────"
    test_state_invalid_json
    test_backup_nonexistent_file

    echo ""
    echo "Workflow Tests"
    echo "─────────────────────────────────────────"
    test_full_backup_restore_workflow
    test_configs_only_workflow

    # Print summary
    print_summary
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
