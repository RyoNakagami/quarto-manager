# quarto-manager

A CLI tool for managing Quarto versions on Linux (Debian/Ubuntu).
Downloads `.deb` packages from GitHub Releases to install, update, and remove Quarto.

## Prerequisites

- Linux (Debian/Ubuntu)
- `curl`
- `sudo`
- `gdebi-core`

```bash
sudo apt-get install curl gdebi-core
```

## Directory Structure

```
quarto-manager/
├── bin/
│   └── quarto-manager      # CLI entry point
├── lib/
│   ├── utils.sh             # Shared helper functions
│   ├── install.sh           # Fresh installation
│   ├── update.sh            # Version update
│   ├── check.sh             # Installation status check
│   └── remove.sh            # Uninstallation
├── tests/                   # bats test suite
├── Dockerfile               # Test container definition
├── docker-compose.yml       # Test runner Compose config
└── README.md
```

## Usage

### Install

```bash
# Install a specific version
quarto-manager install 1.7.32

# Interactive install (fetches latest version from GitHub)
quarto-manager install
```

### Update

```bash
# Update to a specific version
quarto-manager update 1.7.32

# Interactive update (fetches latest version from GitHub)
quarto-manager update
```

### Check Status

```bash
quarto-manager check
```

### Remove

```bash
quarto-manager remove
```

### Help

```bash
quarto-manager help
quarto-manager --version
```

## Unit Testing with Docker

The test environment uses an Ubuntu 24.04 container with [bats-core](https://github.com/bats-core/bats-core) installed.

### 1. Build the Test Image

Run this the first time, or after modifying the `Dockerfile`.

```bash
docker compose build test
```

### 2. Run Tests

```bash
docker compose run --rm test
```

`bin/`, `lib/`, and `tests/` are bind-mounted as read-only from the host, so you can re-run tests after code changes without rebuilding the image.

### 3. Cleanup

Remove containers and images:

```bash
docker compose down --rmi all
```

To also prune unused intermediate layers:

```bash
docker image prune -f
```

## License

[MIT](LICENSE)
