#!/bin/bash
set -e

NETWORK=${1:-testnet}
ARCH=$(uname -m)

echo "🔧 Setting up Walrus environment for $NETWORK ($ARCH)..."

# Determine architecture suffix
if [ "$ARCH" = "x86_64" ]; then
    ARCH_SUFFIX="x64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH_SUFFIX="arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

# Copy the appropriate site-builder to working directory
SITE_BUILDER_SRC="/usr/local/walrus/site-builders/${NETWORK}-${ARCH_SUFFIX}"
if [ -f "$SITE_BUILDER_SRC" ]; then
    cp "$SITE_BUILDER_SRC" ./site-builder
    chmod +x ./site-builder
    echo "✅ Site-builder ready for $NETWORK ($ARCH_SUFFIX)"
else
    echo "❌ Site-builder not found: $SITE_BUILDER_SRC"
    exit 1
fi

# Verify all tools are available
echo "🔍 Verifying installations..."
sui --version
walrus --version
node --version
npm --version
echo "✅ All tools verified"
