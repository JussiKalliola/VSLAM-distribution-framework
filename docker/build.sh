#!/bin/bash

# define a registry to push the images to
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "${SCRIPT}")

REGISTRY=jussikalliola
IMAGE=nano-ros2-orbslam3
VERSION=latest
USE_CACHE="1"
SYSTEM_ARCH=$(uname -m)
TARGET_ROS_DISTRO=humble
DOCKERFILE=$TARGET_ROS_DISTRO.Dockerfile
CACHE_REF=${REGISTRY}/${IMAGE}:buildcache

# Help function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h    Show help information"
  echo "  -v    Version; amd64,arm64,..."
  echo "  -p    Platoforms; arm64,amd64,..."
  echo "  -c    Use Cache"
  echo "  -g    GPU; 1=True, 0=False"
  echo "  -t    Target build; dev,prod,test... Default=dev"
  echo "  -r    Target ROS2 Distro; humble or foxy. Default=humble"
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi



while getopts p:c:v:g:t:r: flag
do
    case "${flag}" in
        p) PLATFORMS=${OPTARG};;
        c) USE_CACHE=${OPTARG};;
        v) VERSION=${OPTARG};;
        g) GPU=${OPTARG};;
        t) TARGET_BUILD=${OPTARG};;
        r) TARGET_ROS_DISTRO=${OPTARG};;
    esac
done

if [ -z "${PLATFORMS}" ]; 
then
  echo "No platforms defined. DEFAULT: linux/${SYSTEM_ARCH}"
  PLATFORMS="linux/${SYSTEM_ARCH}"  
else
  echo "Building for platforms: ${PLATFORMS}"
fi

if [ -z "${TARGET_ROS_DISTRO}" ]; 
then
  echo "No ROS2 Distro defined. DEFAULT: ${TARGET_ROS_DISTRO}"  
else
  echo "Building for platforms: ${PLATFORMS}"
fi


# Check if NVIDIA GPU drivers are available
if [ nvidia-smi &> /dev/null ] && [ "$GPU" == "1" ]; then
  echo "Building a container with GPU support."
  VERSION+="_gpu"
  DOCKERFILE=gpu.Dockerfile
else
  echo "No GPU support."
  DOCKERFILE=humble.Dockerfile
fi

# Check target build, default dev
if [ -z "$TARGET_BUILD" ]; then
  ECHO "No target build given... Default: dev"
  TARGET_BUILD="dev"
fi

BUILD_ARGS=(--build-arg "TARGET_BUILD=${TARGET_BUILD}")
if [[ "$DOCKERFILE" == "humble.Dockerfile" ]]; then
  ORB_SLAM3_IMAGE="${REGISTRY}/nano-ros2-orbslam3-orb:${VERSION}"
  BUILD_ARGS+=(--build-arg "ORB_SLAM3_IMAGE=${ORB_SLAM3_IMAGE}" --pull)
  echo "Using prebuilt ORB-SLAM3 image: ${ORB_SLAM3_IMAGE}"
fi

echo -e "\n============================"
echo -e "Building with params:\n - PLATFORMS=${PLATFORMS}\n - USE CACHE=${USE_CACHE}\n - VERSION=${VERSION}\n - TARGET_BUILD=${TARGET_BUILD}\n - GPU=${GPU}\n - DOCKERFILE=${DOCKERFILE}"
echo -e "============================\n"


# create new buildx that support multiple platforms
docker buildx create --use  --driver-opt network=host --name MultiPlatform

# build the image for two different platforms and push the images
if [ "$USE_CACHE" == "1" ]; then
  
  echo "Building with Cache."

  docker buildx build \
    "${BUILD_ARGS[@]}" \
    --cache-from=type=registry,ref=${CACHE_REF},ignore-error=true \
    --cache-to=type=registry,ref=${CACHE_REF},mode=max \
    --force-rm \
    --progress=plain \
    --platform ${PLATFORMS} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    -f ${DOCKERFILE} .. \
    --push

else

  echo "Building without Cache."

  docker buildx build \
    "${BUILD_ARGS[@]}" \
    --no-cache \
    --force-rm \
    --progress=plain \
    --platform ${PLATFORMS} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    -f ${DOCKERFILE} .. \
    --push
fi
