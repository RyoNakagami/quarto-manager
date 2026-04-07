#!/usr/bin/env bats
# test_cli.bats - Tests for bin/quarto-manager CLI entrypoint

setup() {
    load 'test_helper'
    QUARTO_MANAGER="${BIN_DIR}/quarto-manager"
}

# ──────────────────────────────────────────────
# help / usage
# ──────────────────────────────────────────────
@test "help command shows usage" {
    run "$QUARTO_MANAGER" help
    assert_success
    assert_output --partial "USAGE"
    assert_output --partial "COMMANDS"
}

@test "--help flag shows usage" {
    run "$QUARTO_MANAGER" --help
    assert_success
    assert_output --partial "USAGE"
}

@test "-h flag shows usage" {
    run "$QUARTO_MANAGER" -h
    assert_success
    assert_output --partial "USAGE"
}

@test "no arguments shows usage" {
    run "$QUARTO_MANAGER"
    assert_success
    assert_output --partial "USAGE"
}

# ──────────────────────────────────────────────
# version
# ──────────────────────────────────────────────
@test "--version flag shows version" {
    run "$QUARTO_MANAGER" --version
    assert_success
    assert_output --partial "quarto-manager v"
}

@test "-v flag shows version" {
    run "$QUARTO_MANAGER" -v
    assert_success
    assert_output --partial "quarto-manager v"
}

# ──────────────────────────────────────────────
# unknown command
# ──────────────────────────────────────────────
@test "unknown command fails with error" {
    run "$QUARTO_MANAGER" foobar
    assert_failure
    assert_output --partial "Unknown command: foobar"
}

# ──────────────────────────────────────────────
# check command (quarto not installed in container)
# ──────────────────────────────────────────────
@test "check command warns when quarto is not installed" {
    if command -v quarto &>/dev/null; then
        skip "quarto is installed; skipping not-installed test"
    fi
    run "$QUARTO_MANAGER" check
    assert_failure
    assert_output --partial "not installed"
}

# ──────────────────────────────────────────────
# remove command (quarto not installed in container)
# ──────────────────────────────────────────────
@test "remove command is no-op when quarto is not installed" {
    if command -v quarto &>/dev/null; then
        skip "quarto is installed; skipping not-installed test"
    fi
    run "$QUARTO_MANAGER" remove
    assert_success
    assert_output --partial "not installed"
}

# ──────────────────────────────────────────────
# install command with invalid version
# ──────────────────────────────────────────────
@test "install rejects already-installed quarto" {
    if ! command -v quarto &>/dev/null; then
        skip "quarto is not installed; skipping already-installed test"
    fi
    run "$QUARTO_MANAGER" install 1.7.32
    assert_failure
    assert_output --partial "already installed"
}
