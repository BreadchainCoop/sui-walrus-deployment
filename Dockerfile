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

# Download site-builder binaries (only x86_64 Ubuntu binaries are available)
# Note: Per Walrus documentation, only ubuntu-x86_64 binaries exist for Ubuntu
RUN echo "📥 Downloading site-builder binaries (ubuntu-x86_64 only available)..." && \
    curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-testnet-latest-ubuntu-x86_64" \
        -o /usr/local/bin/site-builder-testnet && \
    curl -L "https://storage.googleapis.com/mysten-walrus-binaries/site-builder-mainnet-latest-ubuntu-x86_64" \
        -o /usr/local/bin/site-builder-mainnet && \
    chmod +x /usr/local/bin/site-builder-* && \
    # Create a default symlink to testnet version
    ln -s /usr/local/bin/site-builder-testnet /usr/local/bin/site-builder && \
    echo "✅ Site-builder binaries installed (ubuntu-x86_64)"

# Copy and install the setup script
COPY walrus-setup.sh /usr/local/bin/walrus-setup
RUN chmod +x /usr/local/bin/walrus-setup

# Verify final installations
RUN sui --version && \
    walrus --version && \
    node --version && \
    npm --version && \
    ls -la /usr/local/bin/site-builder*

WORKDIR /workspace

# Set default entrypoint
CMD ["/bin/bash"]
