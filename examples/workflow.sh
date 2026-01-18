#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Workflow Examples
# ═══════════════════════════════════════════════════════════════════════════════
# This script demonstrates common workflows and usage patterns for Vibe Palace.
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Change to the Vibe Palace directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                  Vibe Palace - Workflow Examples                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 1: First-Time Setup
# ═══════════════════════════════════════════════════════════════════════════════

workflow_1_first_time_setup() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 1: First-Time Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow sets up a basic development environment from scratch."
    echo ""
    echo "Commands:"
    echo "  ./vibe install mercury    # Install terminal tools"
    echo "  ./vibe install venus      # Install editor (Neovim)"
    echo "  ./vibe install uranus     # Install dev tools (Git, Docker, etc.)"
    echo ""
    echo "Estimated time: 25 minutes"
    echo ""

    read -p "Run this workflow? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe install mercury
        ./vibe install venus
        ./vibe install uranus
        echo ""
        echo "✅ Basic development environment ready!"
        echo ""
        echo "Next steps:"
        echo "  - Open a new terminal to see changes"
        echo "  - Run: nvim to test your editor"
        echo "  - Run: ./vibe doctor to verify installation"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 2: Web Development Setup
# ═══════════════════════════════════════════════════════════════════════════════

workflow_2_web_development() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 2: Web Development Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow sets up a full-stack web development environment."
    echo ""
    echo "Commands:"
    echo "  ./vibe install mercury    # Terminal tools"
    echo "  ./vibe install venus      # Editor"
    echo "  ./vibe install mars       # Languages (Node.js, Python)"
    echo "  ./vibe install jupiter    # Databases"
    echo "  ./vibe install uranus     # Dev tools"
    echo ""
    echo "Estimated time: 45 minutes"
    echo ""

    read -p "Run this workflow? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe install mercury
        ./vibe install venus
        ./vibe install mars
        ./vibe install jupiter
        ./vibe install uranus
        echo ""
        echo "✅ Web development environment ready!"
        echo ""
        echo "Next steps:"
        echo "  - fnm install 20  # Install Node.js 20"
        echo "  - fnm use 20     # Use Node.js 20"
        echo "  - npm install -g yarn  # Install Yarn"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 3: Backup and Restore
# ═══════════════════════════════════════════════════════════════════════════════

workflow_3_backup_restore() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 3: Backup and Restore"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow demonstrates backup and restore functionality."
    echo ""
    echo "Commands:"
    echo "  ./vibe backup                 # Create full backup"
    echo "  ./vibe backup --configs       # Backup configs only"
    echo "  ./vibe backup --list          # List backups"
    echo "  ./vibe restore <backup-file>  # Restore from backup"
    echo ""

    read -p "Create a backup now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe backup
        echo ""
        echo "✅ Backup created!"
        echo ""
        echo "To restore on a new machine:"
        echo "  1. Copy backup file to new machine"
        echo "  2. Clone Vibe Palace repository"
        echo "  3. Run: ./vibe restore <backup-file>"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 4: Health Check and Maintenance
# ═══════════════════════════════════════════════════════════════════════════════

workflow_4_health_check() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 4: Health Check and Maintenance"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow checks system health and performs maintenance."
    echo ""
    echo "Commands:"
    echo "  ./vibe status                 # Show installed planets"
    echo "  ./vibe doctor                 # Run health checks"
    echo "  ./vibe list                   # List all planets"
    echo ""

    read -p "Run health check now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe status
        echo ""
        ./vibe doctor
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 5: Dependency Exploration
# ═══════════════════════════════════════════════════════════════════════════════

workflow_5_dependency_exploration() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 5: Dependency Exploration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow shows how to explore planet dependencies."
    echo ""
    echo "Commands:"
    echo "  ./vibe tree saturn    # Show Saturn's dependency tree"
    echo "  ./vibe graph          # Show full dependency graph"
    echo ""

    read -p "Show dependency graph? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe graph
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 6: Uninstall and Reinstall
# ═══════════════════════════════════════════════════════════════════════════════

workflow_6_uninstall_reinstall() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 6: Uninstall and Reinstall"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow demonstrates uninstalling and reinstalling a planet."
    echo ""
    echo "Commands:"
    echo "  ./vibe uninstall mercury   # Remove a planet"
    echo "  ./vibe install mercury     # Reinstall it"
    echo ""

    read -p "Show uninstall example? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "To uninstall a planet:"
        echo "  ./vibe uninstall <planet>"
        echo ""
        echo "Example:"
        echo "  ./vibe uninstall pluto"
        echo ""
        echo "This will:"
        echo "  - Remove binaries"
        echo "  - Remove configurations"
        echo "  - Update state"
        echo ""
        echo "To reinstall:"
        echo "  ./vibe install pluto"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 7: Dry Run Testing
# ═══════════════════════════════════════════════════════════════════════════════

workflow_7_dry_run() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Workflow 7: Dry Run Testing"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This workflow demonstrates using dry-run mode to test installations."
    echo ""
    echo "Commands:"
    echo "  ./vibe install --dry-run saturn    # See what would be installed"
    echo "  ./vibe install --dry-run --all     # See all planets"
    echo ""

    read -p "Run a dry-run example? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./vibe install --dry-run saturn
        echo ""
        echo "✅ Dry run complete! No changes were made."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    echo ""
    echo "Available Workflows:"
    echo ""
    echo "  1) First-Time Setup"
    echo "  2) Web Development Setup"
    echo "  3) Backup and Restore"
    echo "  4) Health Check and Maintenance"
    echo "  5) Dependency Exploration"
    echo "  6) Uninstall and Reinstall"
    echo "  7) Dry Run Testing"
    echo "  q) Quit"
    echo ""
    read -p "Select a workflow (1-7 or q): " choice
    echo ""

    case $choice in
        1) workflow_1_first_time_setup ;;
        2) workflow_2_web_development ;;
        3) workflow_3_backup_restore ;;
        4) workflow_4_health_check ;;
        5) workflow_5_dependency_exploration ;;
        6) workflow_6_uninstall_reinstall ;;
        7) workflow_7_dry_run ;;
        q|Q) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}

# Main loop
while true; do
    show_menu
done
