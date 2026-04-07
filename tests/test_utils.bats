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
# check_dependencies
# ──────────────────────────────────────────────
@test "check_dependencies succeeds when all deps present" {
    run check_dependencies
    assert_success
}
