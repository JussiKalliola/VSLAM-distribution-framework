#!/bin/bash

# define a registry to push the images to
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "${SCRIPT}")

REGISTRY=jussikalliola
IMAGE=nano-ros2-orbslam3-base
VERSION=latest
USE_CACHE="1"
SYSTEM_ARCH=$(uname -m)
ARCH=arm64
TARGET_ROS_DISTRO=humble
DOCKERFILE=base.Dockerfile

# Help function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h    Show help information"
  echo "  -p    Platoforms; arm64,amd64,..."
  echo "  -c    Use Cache"
  echo "  -t    Target build; dev,prod,test... Default=dev"
  echo "  -r    Target ROS2 Distro; humble or foxy. Default=humble"
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi



while getopts v:p:c:t:r: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
        p) PLATFORMS=${OPTARG};;
        c) USE_CACHE=${OPTARG};;
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


if [ "$SYSTEM_ARCH" == "x86_64" ]; then
 ARCH="amd64"
else
 ARCH="arm64"
fi


# Check target build, default dev
if [ -z "$TARGET_BUILD" ]; then
  echo "No target build given... Default: dev"
  TARGET_BUILD="dev"
fi

echo -e "\n============================"
echo -e "Building with params:\n - PLATFORMS=${PLATFORMS}\n - USE CACHE=${USE_CACHE}\n - VERSION=${VERSION}\n - TARGET_BUILD=${TARGET_BUILD}"
echo -e "============================\n"


# create new buildx that support multiple platforms
docker buildx create --use  --driver-opt network=host --name MultiPlatform

# build the image for two different platforms and push the images
if [ "$USE_CACHE" == "1" ]; then
  
  echo "Building with Cache."

  docker buildx build \
    --build-arg TARGET_BUILD=${TARGET_BUILD} \
    --build-arg ARCH=${ARCH} \
    --cache-from=type=registery,ref=${REGISTRY}/${IMAGE}:${VERSION} \
    --force-rm \
    --progress=plain \
    --platform ${PLATFORMS} \
    -f ${DOCKERFILE} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    --push .

else

  echo "Building without Cache."

  docker buildx build \
    --build-arg TARGET_BUILD=${TARGET_BUILD} \
    --build-arg ARCH=${ARCH} \
    --no-cache \
    --force-rm \
    --progress=plain \
    --platform ${PLATFORMS} \
    -f ${DOCKERFILE} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    --push .
fi
