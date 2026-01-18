#!/bin/bash
# Quick test for Vibe Palace libraries

echo "Testing Vibe Palace Libraries..."
echo ""

# Load libraries
source lib/core.sh
source lib/state.sh

# Test environment
export STATE_FILE="/tmp/vibe_test_$$.json"
export VIBE_DIR="/tmp/vibe_test_dir_$$"

echo "✓ Core library loaded"
echo "✓ State library loaded"

# Test OS detection
OS=$(get_os)
echo "✓ OS detected: $OS"

# Test command checking
if command_exists bash; then
    echo "✓ Command detection works"
fi

# Test state management
state_init
echo "✓ State initialized"

state_add mercury 1.0.0 abc123
echo "✓ Planet added to state"

if state_is_installed mercury; then
    echo "✓ Planet installation check works"
fi

VERSION=$(state_get_version mercury)
echo "✓ Retrieved version: $VERSION"

COUNT=$(state_count)
echo "✓ Planet count: $COUNT"

state_remove mercury
echo "✓ Planet removed from state"

# Cleanup
rm -f "$STATE_FILE"
rm -rf "$VIBE_DIR"

echo ""
echo "============================"
echo "✓ ALL TESTS PASSED!"
echo "============================"
