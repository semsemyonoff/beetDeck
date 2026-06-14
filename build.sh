#!/usr/bin/env bash
# Build and push the multi-arch beetDeck production image from the pinned
# submodules. Build context is this repo root (see Dockerfile).
#
# Shared by the local `make release` AND by both CI pipelines (GitHub Actions →
# Docker Hub + GHCR; Forgejo Actions → git.horn). The caller picks the targets:
#
#   BEETDECK_IMAGES   space/newline-separated list of image refs WITHOUT tag
#                     (default: semsemyonoff/beetdeck). Every image is tagged
#                     with every BEETDECK_TAGS value in a single buildx --push,
#                     so the image is built ONCE and fanned out to all targets.
#   BEETDECK_TAGS     space-separated list of tags (default: latest)
#   BEETDECK_VERSION  product version baked into the image as APP_VERSION (the
#                     backend reports it as the OpenAPI info.version). Defaults to
#                     the first non-"latest" tag, then to ./VERSION, then 0.0.0 —
#                     so CI needs no extra wiring (the release version is already
#                     the first BEETDECK_TAGS value).
#   BEETDECK_PLATFORMS  buildx platforms (default: linux/amd64,linux/arm64)
#
# `docker login` to each target registry must already be done by the caller.
# Back-compat: the old singular BEETDECK_IMAGE / BEETDECK_TAG are still honored.
set -euo pipefail
cd "$(dirname "$0")"

IMAGES="${BEETDECK_IMAGES:-${BEETDECK_IMAGE:-semsemyonoff/beetdeck}}"
TAGS="${BEETDECK_TAGS:-${BEETDECK_TAG:-latest}}"
PLATFORMS="${BEETDECK_PLATFORMS:-linux/amd64,linux/arm64}"

# Product version baked into the image (APP_VERSION). Prefer an explicit
# BEETDECK_VERSION; otherwise take the first tag that isn't "latest" (CI passes
# "$version latest"), then fall back to ./VERSION, then 0.0.0.
VERSION="${BEETDECK_VERSION:-}"
if [ -z "$VERSION" ]; then
    for t in $TAGS; do
        if [ "$t" != latest ]; then VERSION="$t"; break; fi
    done
fi
VERSION="${VERSION:-$(cat VERSION 2>/dev/null || echo 0.0.0)}"

for sub in backend frontend; do
    if [ ! -e "$sub/.git" ]; then
        echo "ERROR: submodule '$sub' not initialized — run 'git submodule update --init'." >&2
        exit 1
    fi
done

# Fan out: one --tag per (image, tag) pair → built once, pushed everywhere.
tag_args=()
refs=()
for img in $IMAGES; do
    for t in $TAGS; do
        tag_args+=( --tag "${img}:${t}" )
        refs+=( "${img}:${t}" )
    done
done
echo ">> building ${PLATFORMS} (APP_VERSION=${VERSION}) and pushing:"
printf '   %s\n' "${refs[@]}"

BUILDER="beetDeck-multiarch"
if ! docker buildx inspect "$BUILDER" &>/dev/null; then
    docker buildx create --name "$BUILDER" --use
else
    docker buildx use "$BUILDER"
fi

docker buildx build \
    --platform "$PLATFORMS" \
    --build-arg "APP_VERSION=${VERSION}" \
    "${tag_args[@]}" \
    --push .
