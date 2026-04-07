#!/bin/bash
# =============================================================================
# check.sh - Check Quarto installation status
# =============================================================================
#
# Description:
#   Display Quarto installation status and diagnostic information.
#   Shows the version number and executable path, then runs `quarto check`
#   to output full environment diagnostics.
#
# Functions:
#   - run_check : Display version/path and run `quarto check`
#
# Prerequisites:
#   - utils.sh must be sourced beforehand
#
# Examples:
#   quarto-manager check
# =============================================================================

set -euo pipefail

run_check() {
    if ! is_quarto_installed; then
        warn "Quarto is not installed."
        return 1
    fi

    info "Quarto version: $(get_current_version)"
    info "Quarto path: $(command -v quarto)"
    echo ""
    info "Running 'quarto check'..."
    echo ""
    quarto check
}
