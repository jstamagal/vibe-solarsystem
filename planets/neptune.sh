#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Vibe Palace - Planet: Neptune
# ═══════════════════════════════════════════════════════════════════════════════
# Description: Containers & Orchestration - Container ecosystems
# Duration: ~12 min
# Dependencies: uranus
#
# Tools:
#   - Docker + Docker Compose
#   - kubectl + helm
#   - kind/minikube (local Kubernetes)
#   - podman (alternative container runtime)
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

PLANET_NAME="neptune"
PLANET_VERSION="1.0.0"
PLANET_DESC="Containers & Orchestration - Docker, Kubernetes, podman"

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
  "duration": "12 min"
}
EOF
}

# planet_dependencies: Declare dependencies on other planets
planet_dependencies() {
    # Neptune depends on Uranus (dev tools)
    echo "uranus"
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

# install_docker: Install Docker and Docker Compose
install_docker() {
    step "Installing Docker"

    if command_exists docker; then
        log "Docker already installed"
        local docker_version
        docker_version=$(docker --version 2>/dev/null || echo "unknown")
        log "Current version: $docker_version"
        return 0
    fi

    # Use Docker's convenience script
    log "Installing Docker using official script..."
    if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null; then
        sh /tmp/get-docker.sh
        rm -f /tmp/get-docker.sh
        success "Docker installed"

        # Add user to docker group
        log "Adding user to docker group..."
        if command_exists sudo; then
            sudo usermod -aG docker "$USER" 2>/dev/null || true
            log "User added to docker group (logout/login for changes to take effect)"
        fi
    else
        error "Failed to download Docker installation script"
        return 1
    fi
}

# install_docker_compose: Install Docker Compose plugin
install_docker_compose() {
    step "Installing Docker Compose"

    # Docker Compose V2 is included with Docker Desktop
    # Check if it's available
    if docker compose version &>/dev/null; then
        local compose_version
        compose_version=$(docker compose version --short 2>/dev/null || echo "unknown")
        success "Docker Compose already installed: $compose_version"
        return 0
    fi

    # Try to install via Homebrew as fallback
    if command_exists brew; then
        brew install docker-compose 2>/dev/null || true
        success "Docker Compose installed via Homebrew"
    fi
}

# install_kubectl: Install Kubernetes CLI
install_kubectl() {
    step "Installing kubectl (Kubernetes CLI)"

    if command_exists kubectl; then
        local kubectl_version
        kubectl_version=$(kubectl version --client --short 2>/dev/null || echo "unknown")
        log "kubectl already installed: $kubectl_version"
        return 0
    fi

    # Install via curl (recommended method)
    log "Installing kubectl via curl..."
    if curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 2>/dev/null; then
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/ 2>/dev/null || sudo mv kubectl /usr/bin/ 2>/dev/null || mv kubectl "$HOME/.local/bin/"
        success "kubectl installed"
    else
        # Fallback to Homebrew
        brew install kubectl
        success "kubectl installed via Homebrew"
    fi
}

# install_helm: Install Helm (Kubernetes package manager)
install_helm() {
    step "Installing Helm (Kubernetes package manager)"

    if command_exists helm; then
        local helm_version
        helm_version=$(helm version --short 2>/dev/null || echo "unknown")
        log "Helm already installed: $helm_version"
        return 0
    fi

    # Install via script (recommended method)
    log "Installing Helm via script..."
    if curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 2>/dev/null; then
        chmod +x get_helm.sh
        ./get_helm.sh
        rm -f get_helm.sh
        success "Helm installed"
    else
        # Fallback to Homebrew
        brew install helm
        success "Helm installed via Homebrew"
    fi
}

# install_kind: Install kind (Kubernetes in Docker)
install_kind() {
    step "Installing kind (Kubernetes in Docker)"

    if command_exists kind; then
        log "kind already installed"
        return 0
    fi

    # Install via Go install or Homebrew
    if command_exists brew; then
        brew install kind
        success "kind installed"
    elif command_exists go; then
        go install sigs.k8s.io/kind@latest
        success "kind installed via Go"
    else
        warn "Could not install kind (need brew or go)"
    fi
}

# install_minikube: Install minikube (local Kubernetes)
install_minikube() {
    step "Installing minikube (local Kubernetes)"

    if command_exists minikube; then
        log "minikube already installed"
        return 0
    fi

    # Install via Homebrew
    if command_exists brew; then
        brew install minikube
        success "minikube installed"
    else
        warn "Could not install minikube (need brew)"
    fi
}

# install_podman: Install podman (alternative container runtime)
install_podman() {
    step "Installing podman (alternative container runtime)"

    if command_exists podman; then
        log "podman already installed"
        return 0
    fi

    # Install via Homebrew
    if command_exists brew; then
        brew install podman
        success "podman installed"
    else
        warn "Could not install podman (need brew)"
    fi
}

# configure_shell_aliases: Add convenient aliases
configure_shell_aliases() {
    step "Adding shell aliases"

    local aliases_file="$HOME/.vibe-palace/neptune_aliases.sh"

    cat > "$aliases_file" << 'ALIASES'
# Vibe Palace - Neptune Container Aliases

# Docker
alias d='docker'
alias dc='docker compose'
alias dcp='docker compose pull'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dce='docker compose exec'
alias dcl='docker compose logs'
alias dcb='docker compose build'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Helm
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade'
alias hl='helm list'
alias hh='helm history'

# kind
alias kind-cluster='kind create cluster --name vibepalace'
alias kind-delete='kind delete cluster --name vibepalace'

# minikube
alias mk-start='minikube start'
alias mk-stop='minikube stop'
alias mk-status='minikube status'
ALIASES

    success "Shell aliases created"
    log ""
    log "Add the following to your ~/.bashrc or ~/.zshrc:"
    log "  source ~/.vibe-palace/neptune_aliases.sh"
}

# planet_install: Main installation logic
planet_install() {
    banner "🌑 NEPTUNE: Containers & Orchestration"

    # Pre-flight check: already installed?
    if planet_is_installed; then
        log "Neptune already installed, skipping..."
        return 0
    fi

    # Check for Homebrew
    if ! check_homebrew; then
        return 1
    fi

    # Install Docker
    install_docker
    install_docker_compose

    # Install Kubernetes tools
    install_kubectl
    install_helm

    # Install local Kubernetes (optional - kind/minikube)
    if ask_yes_no "Install kind (Kubernetes in Docker)?"; then
        install_kind
    fi

    if ask_yes_no "Install minikube (local Kubernetes)?"; then
        install_minikube
    fi

    # Install podman (optional)
    if ask_yes_no "Install podman (alternative to Docker)?"; then
        install_podman
    fi

    # Configure shell aliases
    configure_shell_aliases

    # Update state
    state_add "$PLANET_NAME" "$PLANET_VERSION"

    success "Neptune installation complete!"
    log ""
    log "Installed tools:"
    log "  • Docker + Docker Compose"
    log "  • kubectl + helm"
    log "  • kind/minikube (if selected)"
    log "  • podman (if selected)"
    log ""
    log "Next steps:"
    log "  1. Verify Docker installation:"
    log "     docker --version"
    log "     docker run hello-world"
    log ""
    log "  2. Source aliases in your shell config:"
    log "     source ~/.vibe-palace/neptune_aliases.sh"
    log ""
    log "  3. If you just added yourself to docker group, logout/login first"
    log ""
    log "  4. Try creating a local Kubernetes cluster:"
    log "     kind create cluster --name vibepalace"
    log "     kubectl get nodes"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# planet_uninstall: Remove planet and clean up
planet_uninstall() {
    banner "🌑 Uninstalling Neptune"

    # Check if installed
    if ! planet_is_installed; then
        warn "Neptune not installed, nothing to uninstall"
        return 0
    fi

    step "Removing Neptune tools"

    warn "Note: Container runtimes require careful removal"
    warn "Docker data, images, and containers will be preserved"
    warn "To completely remove Docker, use: sudo apt-get purge docker*"

    # Remove kind
    if command_exists kind; then
        log "Removing kind..."
        # Delete any clusters first
        kind delete clusters --all 2>/dev/null || true
        if command_exists brew; then
            brew uninstall kind 2>/dev/null || true
        fi
        success "kind removed"
    fi

    # Remove minikube
    if command_exists minikube; then
        log "Removing minikube..."
        minikube delete 2>/dev/null || true
        if command_exists brew; then
            brew uninstall minikube 2>/dev/null || true
        fi
        success "minikube removed"
    fi

    # Remove podman
    if command_exists podman; then
        log "Removing podman..."
        if command_exists brew; then
            brew uninstall podman 2>/dev/null || true
        fi
        success "podman removed"
    fi

    # Remove kubectl
    if command_exists kubectl; then
        log "Removing kubectl..."
        sudo rm -f /usr/local/bin/kubectl 2>/dev/null || \
        sudo rm -f /usr/bin/kubectl 2>/dev/null || \
        rm -f "$HOME/.local/bin/kubectl" 2>/dev/null || true
        success "kubectl removed"
    fi

    # Remove helm
    if command_exists helm; then
        log "Removing helm..."
        if command_exists brew; then
            brew uninstall helm 2>/dev/null || true
        else
            sudo rm -f /usr/local/bin/helm 2>/dev/null || true
        fi
        success "helm removed"
    fi

    # Note: We don't remove Docker itself as it requires system-level changes
    warn "Docker was NOT removed (requires manual system-level removal)"

    # Remove aliases file
    step "Removing shell aliases"
    if [[ -f "$HOME/.vibe-palace/neptune_aliases.sh" ]]; then
        rm -f "$HOME/.vibe-palace/neptune_aliases.sh"
        success "Aliases file removed"
    fi

    # Remove from state
    state_remove "$PLANET_NAME"

    success "Neptune uninstalled"
    log ""
    log "NOTE: Uranus (dev tools) was NOT removed"
    log "      Each planet is independent!"
    log ""
    log "NOTE: Docker, images, and containers were preserved"
    log "      To completely remove Docker:"
    log "      sudo apt-get purge docker-ce docker-ce-cli containerd.io"

    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

# planet_check_health: Verify planet is working correctly
planet_check_health() {
    local failed=0

    echo "Checking Neptune health..."

    # Check Docker
    if command_exists docker; then
        local docker_version
        docker_version=$(docker --version 2>/dev/null || echo "unknown")
        success "Docker: $docker_version"

        # Try to connect to Docker daemon
        if docker info &>/dev/null; then
            success "Docker daemon is running"
        else
            warn "Docker daemon is not running or not accessible"
        fi
    else
        error "Docker not found in PATH"
        ((failed++))
    fi

    # Check Docker Compose
    if docker compose version &>/dev/null; then
        local compose_version
        compose_version=$(docker compose version --short 2>/dev/null || echo "unknown")
        success "Docker Compose: $compose_version"
    else
        warn "Docker Compose not found"
    fi

    # Check kubectl
    if command_exists kubectl; then
        local kubectl_version
        kubectl_version=$(kubectl version --client --short 2>/dev/null || echo "unknown")
        success "kubectl: $kubectl_version"
    else
        error "kubectl not found in PATH"
        ((failed++))
    fi

    # Check helm
    if command_exists helm; then
        local helm_version
        helm_version=$(helm version --short 2>/dev/null || echo "unknown")
        success "Helm: $helm_version"
    else
        error "Helm not found in PATH"
        ((failed++))
    fi

    # Check kind
    if command_exists kind; then
        success "kind installed"
    else
        warn "kind not found (optional)"
    fi

    # Check minikube
    if command_exists minikube; then
        success "minikube installed"
    else
        warn "minikube not found (optional)"
    fi

    # Check podman
    if command_exists podman; then
        success "podman installed"
    else
        warn "podman not found (optional)"
    fi

    # Check aliases file
    echo ""
    if [[ -f "$HOME/.vibe-palace/neptune_aliases.sh" ]]; then
        success "Shell aliases file exists"
    else
        warn "Shell aliases file not found"
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

    success "Neptune is healthy"
    return 0
}

# planet_is_installed: Quick check if planet is installed
planet_is_installed() {
    # Check critical components
    command_exists docker && \
        command_exists kubectl && \
        command_exists helm && \
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
