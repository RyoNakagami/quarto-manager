#!/bin/bash
# =============================================================================
# utils.sh - Shared helper functions for quarto-manager
# =============================================================================
#
# Description:
#   Common utility functions used across all quarto-manager modules
#   (install, update, check, remove). Provides colored logging, version
#   validation, download helpers, user prompts, and dependency checks.
#
# Functions:
#   - info / warn / error        : Colored log output
#   - validate_version           : Validate semantic version format (X.Y.Z)
#   - is_quarto_installed        : Check if Quarto is installed
#   - get_current_version        : Get the currently installed Quarto version
#   - get_deb_url / get_deb_filename : Build .deb package URL / filename
#   - fetch_latest_version       : Fetch the latest version from GitHub API
#   - download_deb               : Download a .deb package
#   - confirm_action             : Prompt user for yes/no confirmation
#   - prompt_version             : Prompt user for version input
#   - check_dependencies         : Verify required commands (curl, sudo, gdebi)
#
# Usage:
#   source "${LIB_DIR}/utils.sh"
# =============================================================================

# ──────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────
readonly QUARTO_RELEASES_URL="https://github.com/quarto-dev/quarto-cli/releases/download"
readonly QUARTO_LATEST_API="https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest"

# ──────────────────────────────────────────────
# Colors
# ──────────────────────────────────────────────
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly BOLD='\033[1m'
    readonly RESET='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly BOLD=''
    readonly RESET=''
fi

# ──────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────
info() {
    echo -e "${GREEN}[INFO]${RESET} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

# ──────────────────────────────────────────────
# Validation helpers
# ──────────────────────────────────────────────

# Validate version string format (e.g. 1.7.32)
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid version format: '${version}'. Expected format: X.Y.Z (e.g. 1.7.32)"
        return 1
    fi
}

# Check if quarto is currently installed
is_quarto_installed() {
    command -v quarto &>/dev/null
}

# Get currently installed quarto version
get_current_version() {
    if is_quarto_installed; then
        quarto --version
    else
        echo "not installed"
    fi
}

# ──────────────────────────────────────────────
# Download helpers
# ──────────────────────────────────────────────

# Build .deb download URL for a given version
get_deb_url() {
    local version="$1"
    echo "${QUARTO_RELEASES_URL}/v${version}/quarto-${version}-linux-amd64.deb"
}

# Build .deb filename for a given version
get_deb_filename() {
    local version="$1"
    echo "quarto-${version}-linux-amd64.deb"
}

# Fetch the latest release version from GitHub API
fetch_latest_version() {
    local version
    version=$(curl -fsSL "$QUARTO_LATEST_API" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [[ -z "$version" ]]; then
        error "Failed to fetch the latest version from GitHub."
        return 1
    fi
    echo "$version"
}

# Download .deb file; returns path to downloaded file
download_deb() {
    local version="$1"
    local url
    local filename
    url=$(get_deb_url "$version")
    filename=$(get_deb_filename "$version")

    info "Downloading Quarto v${version}..."
    if ! curl -fSL -o "$filename" "$url"; then
        error "Download failed. Check the version number and your network connection."
        rm -f "$filename"
        return 1
    fi
    echo "$filename"
}

# ──────────────────────────────────────────────
# Prompt helpers
# ──────────────────────────────────────────────

# Ask user for yes/no confirmation
confirm_action() {
    local message="${1:-Continue?}"
    local reply
    read -rp "${message} (y/n): " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Ask user for a version, with optional default
prompt_version() {
    local default="${1:-}"
    local prompt_msg="Enter the Quarto version to install (e.g. 1.7.32)"
    if [[ -n "$default" ]]; then
        prompt_msg="${prompt_msg} [${default}]"
    fi
    local version
    read -rp "${prompt_msg}: " version
    version="${version:-$default}"
    if [[ -z "$version" ]]; then
        error "No version specified."
        return 1
    fi
    validate_version "$version" || return 1
    echo "$version"
}

# ──────────────────────────────────────────────
# Dependency checks
# ──────────────────────────────────────────────
check_dependencies() {
    local missing=()
    for cmd in curl sudo gdebi; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing[*]}"
        error "Install them with: sudo apt-get install ${missing[*]}"
        return 1
    fi
}
