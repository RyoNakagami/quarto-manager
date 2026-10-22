#!/bin/bash
# =============================================================================
# update.sh - Update Quarto to a new version
# =============================================================================
#
# Description:
#   Update an existing Quarto installation to a new version. Removes the
#   current version via dpkg -r, then downloads the target version's .deb
#   package into a temporary directory (mktemp) and installs it with gdebi.
#   The temporary directory is always removed.
#
# Functions:
#   - update_quarto <VERSION>    : Update to the specified version (internal)
#   - run_update [VERSION]       : Entry point. If VERSION is omitted, fetches
#                                  the latest from GitHub API and prompts user
#
# Prerequisites:
#   - utils.sh must be sourced beforehand
#   - curl, sudo, gdebi must be installed
#   - Quarto must be installed (use install if not present)
#
# Examples:
#   quarto-manager update 1.7.32    # Update to a specific version
#   quarto-manager update            # Interactive update with latest version
# =============================================================================

set -euo pipefail

update_quarto() {
    local version="$1"

    if ! is_quarto_installed; then
        error "Quarto is not installed. Use 'quarto-manager install' first."
        return 1
    fi

    check_dependencies || return 1
    validate_version "$version" || return 1

    local current_version
    current_version=$(get_current_version)
    info "Current Quarto version: ${current_version}"

    if [[ "$current_version" == "$version" ]]; then
        info "Quarto is already at version ${version}. Nothing to do."
        return 0
    fi

    if ! confirm_action "Update Quarto from v${current_version} to v${version}?"; then
        info "Update cancelled."
        return 0
    fi

    local tmp_dir
    tmp_dir=$(make_download_dir) || return 1
    # Safety net: remove the temp dir even on interrupt or unexpected exit
    # shellcheck disable=SC2064
    trap "cleanup_download_dir $(printf '%q' "$tmp_dir")" EXIT

    local deb_file
    deb_file=$(download_deb "$version" "$tmp_dir") || return 1

    info "Removing existing Quarto installation..."
    if ! sudo dpkg -r quarto; then
        warn "Quarto was not fully removed, continuing..."
    fi

    info "Installing Quarto v${version}..."
    if ! sudo gdebi --non-interactive "$deb_file"; then
        error "Installation failed."
        cleanup_download_dir "$tmp_dir"
        return 1
    fi

    cleanup_download_dir "$tmp_dir"
    info "Temporary files cleaned up."

    if is_quarto_installed; then
        info "Quarto updated successfully to v$(get_current_version)."
    else
        error "Update completed but quarto command not found."
        return 1
    fi
}

run_update() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        info "Fetching latest version..."
        local latest
        latest=$(fetch_latest_version) || return 1
        version=$(prompt_version "$latest") || return 1
    fi

    update_quarto "$version"
}
