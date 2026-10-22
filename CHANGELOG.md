# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-10-22

### Added

- `--verbose` global option that prints debug logs, including the temporary download directory and `.deb` destination path. It can be placed anywhere on the command line.

### Changed

- `install` and `update` now download the `.deb` package into a private temporary directory created with `mktemp -d` (under `$TMPDIR`, default `/tmp`) instead of the current working directory. The directory is removed after installation, and also on interrupt or unexpected exit.

### Fixed

- `download_deb` now writes its info log to stderr so that stdout contains only the downloaded file path.

## [0.1.0]

### Added

- Initial release of the `quarto-manager` CLI with `install`, `update`, `check`, and `remove` commands.
- Docker-based bats test environment.
