#!/bin/bash
set -e

# Simple script to build and optionally push the Walrus Docker image
# Usage: ./build-docker.sh [push] [tag]

PUSH=${1:-""}
TAG=${2:-"walrus-deployment:latest"}
REGISTRY="ghcr.io"

echo "🐳 Building Walrus deployment Docker image..."

# Build the image
docker build -t "$TAG" .

echo "✅ Image built successfully: $TAG"

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
