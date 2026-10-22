#!/usr/bin/env bats
# test_utils.bats - Tests for lib/utils.sh

setup() {
    load 'test_helper'
}

# ──────────────────────────────────────────────
# validate_version
# ──────────────────────────────────────────────
@test "validate_version accepts valid semver" {
    run validate_version "1.7.32"
    assert_success
}

@test "validate_version accepts single-digit parts" {
    run validate_version "0.0.1"
    assert_success
}

@test "validate_version rejects missing patch" {
    run validate_version "1.7"
    assert_failure
    assert_output --partial "Invalid version format"
}

@test "validate_version rejects empty string" {
    run validate_version ""
    assert_failure
    assert_output --partial "Invalid version format"
}

@test "validate_version rejects alpha characters" {
    run validate_version "1.7.x"
    assert_failure
    assert_output --partial "Invalid version format"
}

@test "validate_version rejects v-prefix" {
    run validate_version "v1.7.32"
    assert_failure
    assert_output --partial "Invalid version format"
}

@test "validate_version rejects four-part version" {
    run validate_version "1.7.32.1"
    assert_failure
    assert_output --partial "Invalid version format"
}

# ──────────────────────────────────────────────
# get_deb_url
# ──────────────────────────────────────────────
@test "get_deb_url builds correct URL" {
    run get_deb_url "1.7.32"
    assert_success
    assert_output "https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.32/quarto-1.7.32-linux-amd64.deb"
}

# ──────────────────────────────────────────────
# get_deb_filename
# ──────────────────────────────────────────────
@test "get_deb_filename builds correct filename" {
    run get_deb_filename "1.7.32"
    assert_success
    assert_output "quarto-1.7.32-linux-amd64.deb"
}

# ──────────────────────────────────────────────
# download_deb
# ──────────────────────────────────────────────
@test "download_deb prints only the file path to stdout" {
    curl() { :; }
    local deb_file
    deb_file=$(download_deb "1.7.32" "$BATS_TEST_TMPDIR" 2>/dev/null)
    [ "$deb_file" = "${BATS_TEST_TMPDIR}/quarto-1.7.32-linux-amd64.deb" ]
}

@test "download_deb does not write to the current directory" {
    curl() { touch "$3"; }
    local dest_dir="${BATS_TEST_TMPDIR}/dest"
    local work_dir="${BATS_TEST_TMPDIR}/work"
    mkdir -p "$dest_dir" "$work_dir"
    cd "$work_dir"
    download_deb "1.7.32" "$dest_dir" >/dev/null 2>&1
    [ -f "${dest_dir}/quarto-1.7.32-linux-amd64.deb" ]
    [ -z "$(ls -A "$work_dir")" ]
}

# ──────────────────────────────────────────────
# make_download_dir / cleanup_download_dir
# ──────────────────────────────────────────────
@test "make_download_dir creates a directory under TMPDIR" {
    local dir
    dir=$(TMPDIR="$BATS_TEST_TMPDIR" make_download_dir)
    [ -d "$dir" ]
    [[ "$dir" == "${BATS_TEST_TMPDIR}/quarto-manager."* ]]
}

@test "cleanup_download_dir removes the directory and its contents" {
    local dir
    dir=$(TMPDIR="$BATS_TEST_TMPDIR" make_download_dir)
    touch "${dir}/quarto.deb"
    cleanup_download_dir "$dir"
    [ ! -e "$dir" ]
}

@test "cleanup_download_dir is a no-op for a missing directory" {
    run cleanup_download_dir "${BATS_TEST_TMPDIR}/does-not-exist"
    assert_success
}

# ──────────────────────────────────────────────
# debug
# ──────────────────────────────────────────────
@test "debug prints nothing when VERBOSE is unset" {
    unset VERBOSE
    run debug "hello"
    assert_success
    assert_output ""
}

@test "debug prints message when VERBOSE=1" {
    VERBOSE=1
    run debug "hello"
    assert_success
    assert_output --partial "[DEBUG]"
    assert_output --partial "hello"
}

@test "download_deb reports destination in verbose mode" {
    curl() { :; }
    VERBOSE=1
    run download_deb "1.7.32" "$BATS_TEST_TMPDIR"
    assert_success
    assert_output --partial "Destination: ${BATS_TEST_TMPDIR}/quarto-1.7.32-linux-amd64.deb"
}

# ──────────────────────────────────────────────
# check_dependencies
# ──────────────────────────────────────────────
@test "check_dependencies succeeds when all deps present" {
    run check_dependencies
    assert_success
}
