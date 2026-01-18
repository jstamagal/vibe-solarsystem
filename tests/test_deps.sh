#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Dependency Resolution Tests
# ═══════════════════════════════════════════════════════════════════════════════
# Test suite for dependency resolution and topological sorting
# Tests: dependency extraction, circular detection, sorting, tree generation
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Get script directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Source core libraries
source "$PROJECT_DIR/lib/core.sh"
source "$PROJECT_DIR/lib/deps.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ═══════════════════════════════════════════════════════════════════════════════
# TEST FRAMEWORK FUNCTIONS
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

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="${3:-Expected to find: $needle}"

    if echo "$haystack" | grep -qF "$needle"; then
        return 0
    else
        test_fail "$msg"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="${3:-Should not contain: $needle}"

    if ! echo "$haystack" | grep -qF "$needle"; then
        return 0
    else
        test_fail "$msg"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PLANET DISCOVERY TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_deps_list_all() {
    test_start "deps_list_all - returns planets"

    local planets
    planets=$(deps_list_all)

    if [[ -z "$planets" ]]; then
        test_fail "No planets found"
        return 1
    fi

    # Should have at least mercury
    assert_contains "$planets" "mercury" "Should include mercury"

    test_pass
}

test_deps_planet_exists() {
    test_start "deps_planet_exists - mercury exists"

    if deps_planet_exists "mercury"; then
        test_pass
    else
        test_fail "mercury should exist"
    fi
}

test_deps_planet_not_exists() {
    test_start "deps_planet_exists - nonexistent planet"

    if deps_planet_exists "nonexistent_planet_xyz"; then
        test_fail "nonexistent planet should not exist"
        return 1
    fi

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# DEPENDENCY EXTRACTION TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_deps_get_mercury() {
    test_start "deps_get - mercury has no dependencies"

    local deps
    deps=$(deps_get "mercury" 2>/dev/null || echo "")

    if [[ -n "$deps" ]]; then
        test_fail "mercury should have no dependencies, got: $deps"
        return 1
    fi

    test_pass
}

test_deps_get_venus() {
    test_start "deps_get - venus depends on mercury"

    local deps
    deps=$(deps_get "venus" 2>/dev/null || echo "")

    assert_contains "$deps" "mercury" "venus should depend on mercury"
    test_pass
}

test_deps_get_mars() {
    test_start "deps_get - mars depends on mercury"

    local deps
    deps=$(deps_get "mars" 2>/dev/null || echo "")

    assert_contains "$deps" "mercury" "mars should depend on mercury"
    test_pass
}

test_deps_get_saturn() {
    test_start "deps_get - saturn depends on mars"

    local deps
    deps=$(deps_get "saturn" 2>/dev/null || echo "")

    assert_contains "$deps" "mars" "saturn should depend on mars"
    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# RECURSIVE DEPENDENCY TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_deps_recursive_saturn() {
    test_start "deps_get_all_recursive - saturn includes mars and mercury"

    local deps
    deps=$(deps_get_all_recursive "saturn" 2>/dev/null || echo "")

    # Saturn -> Mars -> Mercury
    assert_contains "$deps" "mars" "Should include mars"
    assert_contains "$deps" "mercury" "Should include mercury"

    # Should not include saturn itself
    assert_not_contains "$deps" "saturn" "Should not include saturn itself"

    test_pass
}

test_deps_recursive_venus() {
    test_start "deps_get_all_recursive - venus includes mercury"

    local deps
    deps=$(deps_get_all_recursive "venus" 2>/dev/null || echo "")

    assert_contains "$deps" "mercury" "Should include mercury"
    assert_not_contains "$deps" "venus" "Should not include venus itself"

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# TOPOLOGICAL SORT TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_deps_sort_mercury() {
    test_start "deps_sort_topological - mercury alone"

    local order
    order=$(deps_sort_topological "mercury" 2>/dev/null || echo "")

    assert_contains "$order" "mercury" "Should include mercury"

    # Mercury should be first (only)
    local first
    first=$(echo "$order" | head -n1)
    if [[ "$first" != "mercury" ]]; then
        test_fail "First should be mercury, got: $first"
        return 1
    fi

    test_pass
}

test_deps_sort_venus() {
    test_start "deps_sort_topological - venus (mercury before venus)"

    local order
    order=$(deps_sort_topological "venus" 2>/dev/null || echo "")

    local mercury_line
    local venus_line

    mercury_line=$(echo "$order" | grep -n "mercury" | cut -d: -f1)
    venus_line=$(echo "$order" | grep -n "venus" | cut -d: -f1)

    if [[ -z "$mercury_line" ]] || [[ -z "$venus_line" ]]; then
        test_fail "Missing planets in order"
        return 1
    fi

    if [[ $mercury_line -gt $venus_line ]]; then
        test_fail "mercury should come before venus"
        return 1
    fi

    test_pass
}

test_deps_sort_saturn() {
    test_start "deps_sort_topological - saturn (mercury < mars < saturn)"

    local order
    order=$(deps_sort_topological "saturn" 2>/dev/null || echo "")

    local mercury_line
    local mars_line
    local saturn_line

    mercury_line=$(echo "$order" | grep -n "mercury" | cut -d: -f1)
    mars_line=$(echo "$order" | grep -n "mars" | cut -d: -f1)
    saturn_line=$(echo "$order" | grep -n "saturn" | cut -d: -f1)

    if [[ -z "$mercury_line" ]] || [[ -z "$mars_line" ]] || [[ -z "$saturn_line" ]]; then
        test_fail "Missing planets in order"
        return 1
    fi

    # Check ordering: mercury < mars < saturn
    if [[ $mercury_line -gt $mars_line ]]; then
        test_fail "mercury should come before mars"
        return 1
    fi

    if [[ $mars_line -gt $saturn_line ]]; then
        test_fail "mars should come before saturn"
        return 1
    fi

    test_pass
}

test_deps_sort_all() {
    test_start "deps_resolve_install_order - all planets"

    local all_planets
    all_planets=$(deps_list_all)

    local order
    order=$(deps_resolve_install_order $all_planets 2>/dev/null || echo "")

    if [[ -z "$order" ]]; then
        test_fail "Failed to resolve order"
        return 1
    fi

    # Count planets
    local count
    count=$(echo "$order" | grep -c '^' || echo "0")

    if [[ $count -lt 8 ]]; then
        test_fail "Expected at least 8 planets, got: $count"
        return 1
    fi

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# CIRCULAR DEPENDENCY DETECTION TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_no_circular_deps() {
    test_start "deps_detect_circular - no circular dependencies"

    # This should not error (no circular deps in current planets)
    local all_planets
    all_planets=$(deps_list_all)

    if deps_detect_circular $all_planets 2>/dev/null; then
        local has_circular=$?
        if [[ $has_circular -eq 0 ]]; then
            test_fail "Detected circular dependencies when there are none"
            return 1
        fi
    fi

    test_pass
}

# ═══════════════════════════════════════════════════════════════════════════════
# TREE GENERATION TESTS
# ═══════════════════════════════════════════════════════════════════════════════

test_deps_show_tree_mercury() {
    test_start "deps_show_tree - mercury (no deps)"

    local tree
    tree=$(deps_show_tree "mercury" 2>/dev/null || echo "")

    # Tree should be generated without error
    if [[ -z "$tree" ]]; then
        test_fail "Tree generation failed"
        return 1
    fi

    test_pass
}

test_deps_show_tree_saturn() {
    test_start "deps_show_tree - saturn (shows dependency chain)"

    local tree
    tree=$(deps_show_tree "saturn" 2>/dev/null || echo "")

    if [[ -z "$tree" ]]; then
        test_fail "Tree generation failed"
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
    echo "║                  Dependency Test Summary                       ║"
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
        success "All dependency tests passed!"
        return 0
    else
        echo ""
        error "Some dependency tests failed!"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            Vibe Palace - Dependency Test Suite                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Planet Discovery
    echo "Planet Discovery Tests"
    echo "─────────────────────────────────────────"
    test_deps_list_all
    test_deps_planet_exists
    test_deps_planet_not_exists

    echo ""
    echo "Dependency Extraction Tests"
    echo "─────────────────────────────────────────"
    test_deps_get_mercury
    test_deps_get_venus
    test_deps_get_mars
    test_deps_get_saturn

    echo ""
    echo "Recursive Dependency Tests"
    echo "─────────────────────────────────────────"
    test_deps_recursive_saturn
    test_deps_recursive_venus

    echo ""
    echo "Topological Sort Tests"
    echo "─────────────────────────────────────────"
    test_deps_sort_mercury
    test_deps_sort_venus
    test_deps_sort_saturn
    test_deps_sort_all

    echo ""
    echo "Circular Dependency Tests"
    echo "─────────────────────────────────────────"
    test_no_circular_deps

    echo ""
    echo "Tree Generation Tests"
    echo "─────────────────────────────────────────"
    test_deps_show_tree_mercury
    test_deps_show_tree_saturn

    # Print summary
    print_summary
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
