#!/bin/bash
set -euo pipefail

COLOR_RESET='\e[0m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_RED='\e[31m'

log() {
    local level="$1"
    local color="$2"
    local message="$3"
    local timestamp=$(date +"%H:%M:%S")

    printf "[%s] [%b%s%b] %s\n" \
        "$timestamp" "$color" "$level" "$COLOR_RESET" "$message"
}

log_info()    { log "info"    "$COLOR_GREEN" "$1"; }
log_warning() { log "warning" "$COLOR_YELLOW" "$1"; }
log_error()   { log "error"   "$COLOR_RED" "$1"; }

update_packages() {
    log_info "updating packages..."
    sudo apt-get -y update >/dev/null 2>&1 || {
        log_error "failed to update packages!"
        exit 1
    }
    log_info "packages updated."
}

upgrade_packages() {
    log_info "upgrading packages..."
    sudo apt-get -y upgrade >/dev/null 2>&1 || {
        log_error "failed to upgrade packages!"
        exit 1
    }
    log_info "packages upgraded."
}

install_docker() {
    log_info "starting docker installation..."

    if command -v docker >/dev/null 2>&1; then
        log_info "docker is already installed!"
        return 0
    fi

    log_info "installing docker dependencies..."
    sudo apt-get install -y ca-certificates curl >/dev/null 2>&1 || {
        log_error "failed to install dependencies!"
        exit 1
    }

    local keyring_path="/etc/apt/keyrings/docker.asc"

    log_info "setting up docker repository..."

    sudo install -m 0755 -d /etc/apt/keyrings >/dev/null 2>&1 || {
        log_error "failed to create keyrings directory!"
        exit 1
    }

    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o "$keyring_path" >/dev/null 2>&1 || {
        log_error "failed to download docker gpg key!"
        exit 1
    }

    sudo chmod a+r "$keyring_path" >/dev/null 2>&1 || {
        log_error "failed to set keyring permissions!"
        exit 1
    }

    . /etc/os-release
    if [[ "$ID" == "debian" ]]; then
        REPO="https://download.docker.com/linux/debian"
    elif [[ "$ID" == "ubuntu" ]]; then
        REPO="https://download.docker.com/linux/ubuntu"
    else
        log_error "unsupported OS: $ID"
        exit 1
    fi

    echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring_path] $REPO $VERSION_CODENAME stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null || {
        log_error "failed to add docker repository!"
        exit 1
    }

    update_packages
    upgrade_packages

    log_info "installing docker packages..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1 || {
        log_error "failed to install docker packages!"
        exit 1
    }

    log_info "enabling docker service..."
    sudo systemctl enable --now docker.service >/dev/null 2>&1 || {
        log_error "failed to enable docker service!"
        exit 1
    }

    log_info "enabling containerd service..."
    sudo systemctl enable --now containerd.service >/dev/null 2>&1 || {
        log_error "failed to enable containerd service!"
        exit 1
    }

    log_info "docker installed successfully!"
}

main() {
    log_info "CPU count: $(grep -c ^processor /proc/cpuinfo)"
    log_info "CPU frequency: $(grep "MHz" /proc/cpuinfo | head -n 1 | awk '{print $4}') MHz"
    log_info "RAM: $(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024)) MB"
    log_info "RAM using:"
    free -m
    log_info "Disk usage:"
    df -h /

    update_packages
    upgrade_packages

    install_docker

    log_info "verifying docker installation..."
    docker --version >/dev/null 2>&1 || {
        log_error "docker verification failed!"
        exit 1
    }

    chmod +x up.sh
    chmod +x down.sh
    chmod +x build.sh

    ./up.sh

    log_info "deploy completed successfully!"
}

main "$@"
