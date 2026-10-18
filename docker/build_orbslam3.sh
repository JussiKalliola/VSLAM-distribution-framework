#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY=jussikalliola
IMAGE=nano-ros2-orbslam3-orb
VERSION=latest
USE_CACHE=1
PLATFORMS=
BUILDER_NAME=MultiPlatform
CACHE_REF="${REGISTRY}/${IMAGE}:buildcache"

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h    Show help information"
  echo "  -p    Target platforms; e.g. linux/amd64 or linux/arm64"
  echo "  -c    Use Cache; 1=True, 0=False"
  echo "  -v    Image version/tag; default=latest"
  exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
fi

while getopts "hp:c:v:" flag; do
  case "${flag}" in
    h) show_help ;;
    p) PLATFORMS=${OPTARG} ;;
    c) USE_CACHE=${OPTARG} ;;
    v) VERSION=${OPTARG} ;;
  esac
done

if [[ -z "$PLATFORMS" ]]; then
  case "$(uname -m)" in
    x86_64) PLATFORMS=linux/amd64 ;;
    aarch64|arm64) PLATFORMS=linux/arm64 ;;
    *)
      echo "Unsupported host architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
fi

if docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  docker buildx use "$BUILDER_NAME"
else
  docker buildx create --use --driver-opt network=host --name "$BUILDER_NAME"
fi

BUILD_ARGS=(
  --pull
  --force-rm
  --progress=plain
  --platform "$PLATFORMS"
  --file "$SCRIPT_DIR/orbslam3.Dockerfile"
  --tag "${REGISTRY}/${IMAGE}:${VERSION}"
)

if [[ "$USE_CACHE" == "1" ]]; then
  docker buildx build \
    "${BUILD_ARGS[@]}" \
    --cache-from="type=registry,ref=${CACHE_REF},ignore-error=true" \
    --cache-to="type=registry,ref=${CACHE_REF},mode=max" \
    --push \
    "$SCRIPT_DIR/.."
else
  docker buildx build \
    "${BUILD_ARGS[@]}" \
    --no-cache \
    --push \
    "$SCRIPT_DIR/.."
fi
