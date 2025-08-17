# Multi-stage build for Walrus deployment
FROM ubuntu:22.04 AS base

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    jq \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# Verify Rust installation
RUN rustc --version && cargo --version

FROM base AS sui-builder

# Install Sui CLI (this takes the longest, so we do it in a separate stage)
RUN cargo install --locked --git https://github.com/MystenLabs/sui.git --branch testnet sui

FROM base AS final

# Copy Sui binary from builder stage
COPY --from=sui-builder /root/.cargo/bin/sui /usr/local/bin/sui

# Install Walrus CLI for both networks
RUN curl -sSf https://install.wal.app | sh -s -- -n testnet && \
    curl -sSf https://install.wal.app | sh
ENV PATH="/root/.local/bin:$PATH"

# Create directory for site-builder binaries
RUN mkdir -p /usr/local/walrus/site-builders

# Download site-builder binaries for all combinations
RUN curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-testnet-latest-ubuntu-x64" \
    -o /usr/local/walrus/site-builders/testnet-x64 && \
    curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-mainnet-latest-ubuntu-x64" \
    -o /usr/local/walrus/site-builders/mainnet-x64 && \
    curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-testnet-latest-ubuntu-arm64" \
    -o /usr/local/walrus/site-builders/testnet-arm64 && \
    curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-mainnet-latest-ubuntu-arm64" \
    -o /usr/local/walrus/site-builders/mainnet-arm64 && \
    chmod +x /usr/local/walrus/site-builders/*

# Copy and install the setup script
COPY walrus-setup.sh /usr/local/bin/walrus-setup
RUN chmod +x /usr/local/bin/walrus-setup

# Verify final installations
RUN sui --version && \
    walrus --version && \
    node --version && \
    npm --version && \
    ls -la /usr/local/walrus/site-builders/

WORKDIR /workspace

# Set default entrypoint
CMD ["/bin/bash"]
