#!/bin/bash
# test_helper.bash - Common setup for all bats tests

load '/usr/local/lib/bats-support/load'
load '/usr/local/lib/bats-assert/load'

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
BIN_DIR="${PROJECT_ROOT}/bin"
LIB_DIR="${PROJECT_ROOT}/lib"

# Source utils for unit-testing individual functions
source "${LIB_DIR}/utils.sh"
