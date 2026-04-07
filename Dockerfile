# =============================================================================
# Dockerfile - Test environment for quarto-manager
# =============================================================================
#
# Description:
#   Builds an Ubuntu 24.04 container with all runtime dependencies
#   (curl, sudo, gdebi-core) and the bats-core testing framework.
#   Used for running unit tests in an isolated Linux environment.
#
# Build:
#   docker compose build test
#
# Run tests:
#   docker compose run --rm test
#
# Cleanup:
#   docker compose down --rmi all
# =============================================================================

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    sudo \
    gdebi-core \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install bats-core and helper libraries
RUN git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core \
    && /tmp/bats-core/install.sh /usr/local \
    && rm -rf /tmp/bats-core

RUN git clone --depth 1 https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support \
    && git clone --depth 1 https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

WORKDIR /app
COPY . /app/

RUN chmod +x /app/bin/quarto-manager

CMD ["bats", "--recursive", "tests/"]
