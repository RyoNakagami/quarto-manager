#!/bin/bash
# =============================================================================
# remove.sh - Remove Quarto from the system
# =============================================================================
#
# Description:
#   Uninstall Quarto from a Linux system via dpkg -r. Prompts the user for
#   confirmation before proceeding. Safe to run when Quarto is not installed.
#
# Functions:
#   - run_remove : Confirm and remove Quarto
#
# Prerequisites:
#   - utils.sh must be sourced beforehand
#   - sudo access required for dpkg -r
#
# Examples:
#   quarto-manager remove
# =============================================================================

set -euo pipefail

run_remove() {
    if ! is_quarto_installed; then
        warn "Quarto is not installed. Nothing to remove."
        return 0
    fi

    local current_version
    current_version=$(get_current_version)
    info "Found Quarto v${current_version}"

    if ! confirm_action "Remove Quarto v${current_version}?"; then
        info "Removal cancelled."
        return 0
    fi

    info "Removing Quarto..."
    if sudo dpkg -r quarto; then
        info "Quarto removed successfully."
    else
        error "Failed to remove Quarto."
        return 1
    fi
}
