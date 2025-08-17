#!/bin/bash
set -e

# Simple script to build and optionally push the Walrus Docker image
# Usage: ./build-docker.sh [push] [tag]

PUSH=${1:-""}
TAG=${2:-"walrus-deployment:latest"}
REGISTRY="ghcr.io"

echo "🐳 Building Walrus deployment Docker image..."
echo "ℹ️  Note: Building for linux/amd64 (x86_64) because Walrus site-builder only supports ubuntu-x86_64"

# Always build for linux/amd64 since site-builder only has ubuntu-x86_64 binaries
DOCKER_PLATFORM="linux/amd64"

# Build the image with proper platform
docker build --platform "$DOCKER_PLATFORM" -t "$TAG" .

echo "✅ Image built successfully: $TAG (platform: $DOCKER_PLATFORM)"

# Push if requested
if [ "$PUSH" = "push" ]; then
    echo "📤 Pushing to registry..."
    
    # Tag for registry if not already prefixed
    if [[ ! "$TAG" =~ ^$REGISTRY.* ]]; then
        REGISTRY_TAG="$REGISTRY/$TAG"
        docker tag "$TAG" "$REGISTRY_TAG"
        TAG="$REGISTRY_TAG"
    fi
    
    docker push "$TAG"
    echo "✅ Image pushed successfully: $TAG"
fi

echo "🎉 Done!"
echo ""
echo "To use this image locally:"
echo "  docker run -it --rm -v \$(pwd):/workspace $TAG"
echo ""
echo "To test Walrus setup:"
echo "  docker run -it --rm -v \$(pwd):/workspace $TAG walrus-setup testnet"
echo ""
echo "Available site-builder commands:"
echo "  site-builder-testnet  # For testnet"
echo "  site-builder-mainnet  # For mainnet" 
echo "  site-builder          # Default (points to testnet)"
