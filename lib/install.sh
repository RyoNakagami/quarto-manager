#!/bin/bash
# =============================================================================
# install.sh - Fresh Quarto installation
# =============================================================================
#
# Description:
#   Install Quarto on a Linux system. Downloads the specified version's .deb
#   package from GitHub Releases and installs it via gdebi.
#
# Functions:
#   - install_quarto <VERSION>   : Install the specified version (internal)
#   - run_install [VERSION]      : Entry point. If VERSION is omitted, fetches
#                                  the latest from GitHub API and prompts user
#
# Prerequisites:
#   - utils.sh must be sourced beforehand
#   - curl, sudo, gdebi must be installed
#   - Quarto must NOT be installed (use update if already present)
#
# Examples:
#   quarto-manager install 1.7.32   # Install a specific version
#   quarto-manager install           # Interactive install with latest version
# =============================================================================

set -euo pipefail

install_quarto() {
    local version="$1"

    if is_quarto_installed; then
        warn "Quarto is already installed (version: $(get_current_version))."
        warn "Use 'quarto-manager update' to update, or 'quarto-manager remove' first."
        return 1
    fi

    check_dependencies || return 1
    validate_version "$version" || return 1

    info "Installing Quarto v${version}..."

    local deb_file
    deb_file=$(download_deb "$version") || return 1

    info "Running installer..."
    if ! sudo gdebi --non-interactive "$deb_file"; then
        error "Installation failed."
        rm -f "$deb_file"
        return 1
    fi

    rm -f "$deb_file"
    info "Temporary files cleaned up."

    if is_quarto_installed; then
        info "Quarto v$(get_current_version) installed successfully."
    else
        error "Installation completed but quarto command not found."
        return 1
    fi
}

run_install() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        info "Fetching latest version..."
        local latest
        latest=$(fetch_latest_version) || return 1
        version=$(prompt_version "$latest") || return 1
    fi

    install_quarto "$version"
}
