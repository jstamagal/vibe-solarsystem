#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Jupiter
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Databases - Database clients and tools
# Duration: ~8 min
# Dependencies: mercury, mars
#
# Tools:
#   - PostgreSQL client + pgcli
#   - MySQL client + mycli
#   - Redis + iredis
#   - MongoDB shell (mongosh)
#   - SQLite
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

PLANET_NAME="jupiter"
PLANET_VERSION="1.0.0"
PLANET_DESC="Databases - PostgreSQL, MySQL, Redis, MongoDB, SQLite clients"

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
  "duration": "8 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # Jupiter depends on Mercury (terminal tools) and Mars (Python for CLI tools)
    echo "mercury mars"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# check_homebrew: Ensure Homebrew is installed
check_homebrew() {
    if ! command_exists brew; then
        error "Homebrew is not installed"
        log "Please install Homebrew first:"
        log "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    return 0
}

# check_python: Ensure Python is available for CLI tools
check_python() {
    if ! command_exists python3 && ! command_exists python; then
        error "Python is not installed"
        log "Please install Mars planet first for Python support"
        return 1
    fi
    return 0
}

# install_postgresql: Install PostgreSQL client and pgcli
install_postgresql() {
    step "Installing PostgreSQL client and pgcli"

    if command_exists psql; then
        log "PostgreSQL client already installed"
    else
        brew install postgresql@16
        success "PostgreSQL client installed"
    fi

    # Install pgcli (Python-based CLI)
    if command_exists pgcli; then
        log "pgcli already installed"
    else
        if command_exists pip3; then
            pip3 install pgcli --quiet 2>/dev/null || true
            success "pgcli installed"
        else
            warn "pip3 not found, skipping pgcli"
        fi
    fi
}

# install_mysql: Install MySQL client and mycli
install_mysql() {
    step "Installing MySQL client and mycli"

    if command_exists mysql; then
        log "MySQL client already installed"
    else
        brew install mysql-client
        success "MySQL client installed"
    fi

    # Install mycli (Python-based CLI)
    if command_exists mycli; then
        log "mycli already installed"
    else
        if command_exists pip3; then
            pip3 install mycli --quiet 2>/dev/null || true
            success "mycli installed"
        else
            warn "pip3 not found, skipping mycli"
        fi
    fi
}

# install_redis: Install Redis and iredis
install_redis() {
    step "Installing Redis and iredis"

    if command_exists redis-cli; then
        log "Redis already installed"
    else
        brew install redis
        success "Redis installed"
    fi

    # Install iredis (Python-based CLI)
    if command_exists iredis; then
        log "iredis already installed"
    else
        if command_exists pip3; then
            pip3 install iredis --quiet 2>/dev/null || true
            success "iredis installed"
        else
            warn "pip3 not found, skipping iredis"
        fi
    fi
}

# install_mongodb: Install MongoDB shell
install_mongodb() {
    step "Installing MongoDB Shell (mongosh)"

    if command_exists mongosh; then
        log "MongoDB Shell already installed"
    else
        brew install mongosh
        success "MongoDB Shell installed"
    fi
}

# install_sqlite: Install SQLite and litecli
install_sqlite() {
    step "Installing SQLite and litecli"

    if command_exists sqlite3; then
        log "SQLite already installed"
    else
        brew install sqlite
        success "SQLite installed"
    fi

    # Install litecli (Python-based CLI)
    if command_exists litecli; then
        log "litecli already installed"
    else
        if command_exists pip3; then
            pip3 install litecli --quiet 2>/dev/null || true
            success "litecli installed"
        else
            warn "pip3 not found, skipping litecli"
        fi
    fi
}

# planet_install: Main installation logic
planet_install() {
    banner "🪐 JUPITER: Databases"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Jupiter already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Check for Python (for CLI tools)
    check_python

    # Install database clients
    install_postgresql
    install_mysql
    install_redis
    install_mongodb
    install_sqlite

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Jupiter installation complete!"
    log ""
    log "Installed tools:"
    log "  • PostgreSQL client + pgcli"
    log "  • MySQL client + mycli"
    log "  • Redis + iredis"
    log "  • MongoDB Shell (mongosh)"
    log "  • SQLite + litecli"
    log ""
    log "Usage examples:"
    log "  • pgcli -h localhost -U postgres"
    log "  • mycli -h localhost -u root"
    log "  • iredis"
    log "  • mongosh"
    log "  • litecli database.db"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🪐 Uninstalling Jupiter"

    # Check if installed
    if ! planet_is_installed; then
        warn "Jupiter not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Jupiter tools"

    # Remove database clients via Homebrew
    local tools=("postgresql@16" "mysql-client" "redis" "mongosh" "sqlite")

    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            log "Uninstalling $tool..."
            brew uninstall "$tool" 2>/dev/null || true
            success "$tool removed"
        fi
    done

    # Remove Python-based CLI tools
    step "Removing Python-based CLI tools"

    local pip_tools=("pgcli" "mycli" "iredis" "litecli")

    for tool in "${pip_tools[@]}"; do
        if command_exists pip3; then
            if pip3 show "$tool" &>/dev/null; then
                log "Uninstalling $tool..."
                pip3 uninstall "$tool" -y --quiet 2>/dev/null || true
                success "$tool removed"
            fi
        fi
    done

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Jupiter uninstalled"
    log ""
    log "NOTE: Mercury (terminal tools) and Mars (languages) were NOT removed"
    log "      Each planet is independent!"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Jupiter health..."

    # Check PostgreSQL client
    if command_exists psql; then
        local psql_version
        psql_version=$(psql --version 2>/dev/null | awk '{print $3}' || echo "unknown")
        success "PostgreSQL client: $psql_version"
    else
        error "PostgreSQL client not found in PATH"
        ((failed++))
    fi

    # Check pgcli
    if command_exists pgcli; then
        success "pgcli installed"
    else
        warn "pgcli not found (optional Python tool)"
    fi

    # Check MySQL client
    if command_exists mysql; then
        success "MySQL client installed"
    else
        error "MySQL client not found in PATH"
        ((failed++))
    fi

    # Check mycli
    if command_exists mycli; then
        success "mycli installed"
    else
        warn "mycli not found (optional Python tool)"
    fi

    # Check Redis
    if command_exists redis-cli; then
        local redis_version
        redis_version=$(redis-cli --version 2>/dev/null | awk '{print $2}' || echo "unknown")
        success "Redis: $redis_version"
    else
        error "Redis not found in PATH"
        ((failed++))
    fi

    # Check iredis
    if command_exists iredis; then
        success "iredis installed"
    else
        warn "iredis not found (optional Python tool)"
    fi

    # Check MongoDB Shell
    if command_exists mongosh; then
        success "MongoDB Shell installed"
    else
        error "MongoDB Shell not found in PATH"
        ((failed++))
    fi

    # Check SQLite
    if command_exists sqlite3; then
        local sqlite_version
        sqlite_version=$(sqlite3 --version 2>/dev/null | awk '{print $1}' || echo "unknown")
        success "SQLite: $sqlite_version"
    else
        error "SQLite not found in PATH"
        ((failed++))
    fi

    # Check litecli
    if command_exists litecli; then
        success "litecli installed"
    else
        warn "litecli not found (optional Python tool)"
    fi

    # Check state
    echo ""
    if state_is_installed "$PLANET_NAME"; then
        success "State registered"
    else
        error "State not registered"
        ((failed++))
    fi

    # Summary
    echo ""
    if [[ $failed -gt 0 ]]; then
        error "Health check failed: $failed issue(s)"
        return 1
    fi

    success "Jupiter is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists psql && \
        command_exists mysql && \
        command_exists redis-cli && \
        command_exists mongosh && \
        command_exists sqlite3 && \
        state_is_installed "$PLANET_NAME"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

# If script is executed directly (not sourced), run the requested function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        metadata)
            planet_metadata
            ;;
        dependencies)
            planet_dependencies
            ;;
        install)
            planet_install
            ;;
        uninstall)
            planet_uninstall
            ;;
        health)
            planet_check_health
            ;;
        is_installed)
            if planet_is_installed; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {metadata|dependencies|install|uninstall|health|is_installed}"
            echo ""
            echo "Commands:"
            echo "  metadata      Show planet metadata"
            echo "  dependencies  List planet dependencies"
            echo "  install       Install the planet"
            echo "  uninstall     Uninstall the planet"
            echo "  health        Run health check"
            echo "  is_installed  Check if installed"
            exit 1
            ;;
    esac
fi
