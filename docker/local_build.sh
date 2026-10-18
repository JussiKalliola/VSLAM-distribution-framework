#!/bin/bash

# define a registry to push the images to
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "${SCRIPT}")

REGISTRY=jussikalliola
IMAGE=nano-ros2-orbslam3
VERSION=localv1
USE_CACHE="1"
SYSTEM_ARCH=$(uname -m)
DOCKERFILE=Dockerfile

# Help function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h    Show help information"
  echo "  -b    Base image name; default ubuntu:18.04 "
  echo "  -v    Version; default latest"
  echo "  -c    Use Cache"
  echo "  -g    GPU; 1=True, 0=False"
  echo "  -t    Target build; dev,prod,test... Default=dev"
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi



while getopts b:c:v:g:t: flag
do
    case "${flag}" in
        b) BASE_IMAGE=${OPTARG};;
        c) USE_CACHE=${OPTARG};;
        v) VERSION=${OPTARG};;
        g) GPU=${OPTARG};;
        t) TARGET_BUILD=${OPTARG};;
    esac
done

if [ -z "${BASE_IMAGE}" ]; 
then
  echo "No base image defined.. DEFAULT: ubuntu:18.04"
  BASE_IMAGE="ubuntu:18.04"  
else
  echo "Using base image: ${BASE_IMAGE}"
fi


# Check if NVIDIA GPU drivers are available
if [ nvidia-smi &> /dev/null ] && [ "$GPU" == "1" ]; then
  echo "Building a container with GPU support."
  VERSION+="_gpu"
  DOCKERFILE=gpu.Dockerfile
else
  echo "No GPU support."
  DOCKERFILE=local.Dockerfile
fi

# Check target build, default dev
if [ -z "$TARGET_BUILD" ]; then
  echo "No target build given... Default: dev"
  TARGET_BUILD="dev"
fi

echo -e "\n============================"
echo -e "Building with params:\n - BASE_IMAGE=${BASE_IMAGE}\n - USE CACHE=${USE_CACHE}\n - VERSION=${VERSION}\n - TARGET_BUILD=${TARGET_BUILD}\n - GPU=${GPU}"
echo -e "============================\n"


# build the image for two different platforms and push the images
if [ "$USE_CACHE" == "1" ]; then
  
  echo "Building with Cache."

  docker build \
    --build-arg TARGET_BUILD=${TARGET_BUILD} \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    --force-rm \
    --progress=plain \
    -f ${DOCKERFILE} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    .

else

  echo "Building without Cache."

  docker build \
    --build-arg TARGET_BUILD=${TARGET_BUILD} \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    --no-cache \
    --force-rm \
    --progress=plain \
    -f ${DOCKERFILE} \
    -t ${REGISTRY}/${IMAGE}:${VERSION} \
    .
fi
