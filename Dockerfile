# Multi-stage build for Walrus deployment
FROM ubuntu:24.04 AS base

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

FROM base AS final

# Download pre-built Sui CLI binary instead of compiling from source
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PLATFORM="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PLATFORM="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH"; \
        exit 1; \
    fi && \
    echo "Downloading Sui CLI for ubuntu-$PLATFORM..." && \
    # Get the latest release tag and construct the download URL \
    LATEST_TAG=$(curl -s https://api.github.com/repos/MystenLabs/sui/releases/latest | grep '"tag_name":' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/') && \
    DOWNLOAD_URL="https://github.com/MystenLabs/sui/releases/download/${LATEST_TAG}/sui-${LATEST_TAG}-ubuntu-${PLATFORM}.tgz" && \
    echo "Downloading from: $DOWNLOAD_URL" && \
    curl -L "$DOWNLOAD_URL" -o sui.tgz && \
    tar -xzf sui.tgz && \
    chmod +x sui && \
    mv sui /usr/local/bin/sui && \
    rm sui.tgz && \
    sui --version && \
    echo "✅ Sui CLI installed successfully"

# Install Walrus CLI (testnet version, works for both networks)
RUN curl -sSf https://install.wal.app | sh -s -- -n testnet
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
