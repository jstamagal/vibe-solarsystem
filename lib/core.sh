#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Core Library
# ═══════════════════════════════════════════════════════════════════════════════
# Foundation functions for all Vibe Palace planets and tools
# Provides: colors, logging, banners, OS detection, command checking
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# COLOR DEFINITIONS
# �════════════════════════════════════════════════════════════════════════════════

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m'  # No Color

# ═══════════════════════════════════════════════════════════════════════════════
# GLOBAL VARIABLES
# ═══════════════════════════════════════════════════════════════════════════════

export VIBE_DIR="${VIBE_DIR:-$HOME/.vibe-palace}"
export LOG_FILE="${LOG_FILE:-$VIBE_DIR/install.log}"

# Ensure VIBE_DIR exists
mkdir -p "$VIBE_DIR"

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# log: General informational message
# Usage: log "Your message here"
log() {
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    echo -e "${CYAN}[$timestamp]${NC} $1" | tee -a "$LOG_FILE"
}

# success: Success message with checkmark
# Usage: success "Operation completed"
success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

# warn: Warning message with alert symbol
# Usage: warn "Something might be wrong"
warn() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

# error: Error message with X symbol
# Usage: error "Operation failed"
error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

# info: Info message with info symbol
# Usage: info "Processing file..."
info() {
    echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# banner: Display a prominent banner for major sections
# Usage: banner "PHASE 1: INSTALLATION"
banner() {
    local width=80
    local padding=""

    # Calculate padding to center text (approximately)
    local text_length=${#1}
    local total_padding=$(( (width - text_length - 4) / 2 ))
    if [[ $total_padding -gt 0 ]]; then
        padding=$(printf '%*s' "$total_padding" '')
    fi

    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}${padding}${BOLD}  $1${NC}${padding}${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# step: Display a step/phase header
# Usage: step "Installing packages..."
step() {
    echo -e "\n${BOLD}${BLUE}▸ $1${NC}\n"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SYSTEM DETECTION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# get_os: Detect the operating system
# Returns: "linux", "darwin", or "unknown"
# Usage: OS=$(get_os)
get_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "darwin" ;;
        *)          echo "unknown" ;;
    esac
}

# get_distro: Detect Linux distribution
# Returns: Distribution name or "unknown"
# Usage: DISTRO=$(get_distro)
get_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# is_linux: Check if running on Linux
# Returns: 0 if true, 1 if false
# Usage: if is_linux; then ...; fi
is_linux() {
    [[ "$(get_os)" == "linux" ]]
}

# is_macos: Check if running on macOS
# Returns: 0 if true, 1 if false
# Usage: if is_macos; then ...; fi
is_macos() {
    [[ "$(get_os)" == "darwin" ]]
}

# get_arch: Detect system architecture
# Returns: "amd64", "arm64", or similar
# Usage: ARCH=$(get_arch)
get_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)    echo "amd64" ;;
        aarch64)   echo "arm64" ;;
        armv7l)    echo "armv7" ;;
        *)         echo "$arch" ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMMAND CHECKING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# command_exists: Check if a command is available in PATH
# Returns: 0 if exists, 1 if not
# Usage: if command_exists "nvim"; then ...; fi
command_exists() {
    command -v "$1" &> /dev/null
}

# require_commands: Check that all required commands exist
# Exits with error if any command is missing
# Usage: require_commands "git" "curl" "wget"
require_commands() {
    local missing=()

    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required commands: ${missing[*]}"
        return 1
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# ask_yes_no: Prompt user for yes/no confirmation
# Returns: 0 for yes, 1 for no
# Usage: if ask_yes_no "Continue?"; then ...; fi
ask_yes_no() {
    local prompt="$1"
    local response

    while true; do
        read -rp "${CYAN}[?]${NC} $prompt (y/n): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo])     return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# confirm_dangerous_operation: Warn about dangerous operations
# Usage: if confirm_dangerous_operation "delete all files"; then ...; fi
confirm_dangerous_operation() {
    local operation="$1"
    warn "You are about to: $operation"
    warn "This operation may be destructive and cannot be easily undone!"
    ask_yes_no "Are you sure you want to continue?"
}

# download_file: Download a file with progress and error handling
# Usage: download_file "url" "output_path"
download_file() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        error "Neither curl nor wget is available"
        return 1
    fi
}

# ensure_dir: Create directory if it doesn't exist
# Usage: ensure_dir "/path/to/dir"
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log "Created directory: $dir"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# Export all functions so they can be used in subshells
export -f log success warn error info
export -f banner step
export -f get_os get_distro is_linux is_macos get_arch
export -f command_exists require_commands
export -f ask_yes_no confirm_dangerous_operation download_file ensure_dir
