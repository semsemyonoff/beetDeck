#!/usr/bin/env bash
# Build and push the multi-arch beetDeck production image from the pinned
# submodules. Build context is this repo root (see Dockerfile). Invoked by
# `make release`; override IMAGE/TAG/PLATFORMS via the BEETDECK_* env vars.
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${BEETDECK_IMAGE:-semsemyonoff/beetdeck}"
TAG="${BEETDECK_TAG:-latest}"
PLATFORMS="${BEETDECK_PLATFORMS:-linux/amd64,linux/arm64}"

for sub in backend frontend; do
    if [ ! -e "$sub/.git" ]; then
        echo "ERROR: submodule '$sub' not initialized — run 'git submodule update --init'." >&2
        exit 1
    fi
done

BUILDER="beetDeck-multiarch"
if ! docker buildx inspect "$BUILDER" &>/dev/null; then
    docker buildx create --name "$BUILDER" --use
else
    docker buildx use "$BUILDER"
fi

docker buildx build \
    --platform "$PLATFORMS" \
    --tag "${IMAGE}:${TAG}" \
    --push .
