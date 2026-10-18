#!/bin/bash


REGISTRY=jussikalliola
IMAGE=nano-ros2-orbslam3
VERSION=latest
USE_CACHE=1
SYSTEM_ARCH=$(uname -m)
#GPU_SUPPORT=0
PWD=$(pwd)
ROOT_DIR=$PWD/..
USE_HUSARNET=0

# Help function
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h    Show help information"
  echo "  -v    Version; amd64,arm64,..."
#  echo "  -g    GPU; 1=True, 0=False"
  echo "  -t    Target build; dev,prod,test... Default=dev"
  echo "  -n    Container name; tr,lm,lc,... Default="
  echo "  -s    Slam system ID; tr,lm,lc,... Default="
  echo "  -d    Dataset Path. Default="
  echo "  -r    Results Path. Default to root directory results."
  echo "  -m    Displey for x11 forwarding. Default=docker.for.mac.host.internal:0"
  #echo "  -r    Run SLAM system in the beginning, if SLAM SYSTEM ID is not defined, then defaults to bash"
  exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi




while getopts v:t:n:s:d:r:m:h: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
#        g) GPU=${OPTARG};;
        t) TARGET_BUILD=${OPTARG};;
        n) CONTAINER_NAME=${OPTARG};;
        s) SLAM_SYSTEM_ID=${OPTARG};;
        d) DATASET_PATH=${OPTARG};;
        r) RESULTS_PATH=${OPTARG};;
        m) DISP=${OPTARG};;
        h) USE_HUSARNET=${OPTARG};;
        #r) RUN_SLAM=${OPTARG};;
    esac
done

  
# Check version
if [ -z "${VERSION}" ]; 
then
  echo "No version defined. DEFAULT: latest"
  VERSION=latest
else
  echo "Version selected: ${VERSION}"
fi


# Check version
if [ -z "${DISP}" ]; 
then
  echo "No display variable given. DEFAULT: docker.for.mac.host.internal:0"
  DISP=docker.for.mac.host.internal:0
else
  echo "Use DISPLAY environment variable. ${DISPLAY}"
  DISP=${DISPLAY}
fi

# Check version
if [ -z "${SLAM_SYSTEM_ID}" ]; 
then
  echo "No SLAM_SYSTEM_ID. DEFAULT: "
  SLAM_SYSTEM_ID=
else
  echo "SLAM ID selected: ${SLAM_SYSTEM_ID}"
fi

# Check gpu
#if [ nvidia-smi &> /dev/null ] && [ "$GPU" == "1" ]; then
#  echo "Found gpu(s), pulling correct image and enable gpu support."
#  # Here pull right image when its done.
#  #VERSION+="_gpu"
#  #DOCKERFILE=gpu.Dockerfile  
#  GPU_SUPPORT=1
#
#else
#  echo "No GPU support, disable gpu(s)."
#  #DOCKERFILE=Dockerfile
#fi



# Check target build, default dev
if [ -z "$TARGET_BUILD" ]; then
  echo "No target build given. Default: dev"
  TARGET_BUILD="dev"
fi


echo -e "\n============================"
echo -e "Running with params:\n - VERSION=${VERSION}\n - TARGET_BUILD=${TARGET_BUILD}\n  - HOME DIRECTORY=${ROOT_DIR}"
echo -e "============================\n"


echo "Pulling an image: ${REGISTRY}/${IMAGE}:${VERSION}"
docker pull $REGISTRY/$IMAGE:$VERSION

xhost +
params=()
if [[ "$CONTAINER_NAME" ]]; then
  params+=(--name ${CONTAINER_NAME})
fi


if [ "$TARGET_BUILD" == "dev" ]; then
  params+=(-v $ROOT_DIR/ros_ws/:/root/colcon_ws)
  params+=(-v $ROOT_DIR/orbslam3/:/root/colcon_ws/src) 
  params+=(-v $ROOT_DIR/thirdparty/ORB_SLAM3:/root/ORB_SLAM3-dev) 
fi

if [ "$USE_HUSARNET" == "1" ];
then
  source ../.env
  #params+=(--sysctl net.ipv6.conf.all.disable_ipv6=0)
  #params+=(-e HUSARNET_HOSTNAME=$CONTAINER_NAME)
  #params+=(-e HUSARNET_JOIN_CODE=$HUSARNET_JOIN_CODE)
  #params+=(-e HUSARNET_DEBUG=0)
  #params+=(-e FASTRTPS_DEFAULT_PROFILES_FILE=/root/config/dds/husarnet_profile.xml)
  #params+=(-v $ROOT_DIR/config/husarnet:/var/lib/husarnet)
  params+=(--net=container:husarnet-talker)
  params+=(--ipc=container:husarnet-talker)
elif [ "$USE_HUSARNET" == "2" ];
then
  source ../.env
  params+=(--sysctl net.ipv6.conf.all.disable_ipv6=0)
  params+=(-e HUSARNET_HOSTNAME=$CONTAINER_NAME)
  params+=(-e HUSARNET_JOIN_CODE=$HUSARNET_JOIN_CODE)
  params+=(-e HUSARNET_DEBUG=0)
  params+=(-e FASTRTPS_DEFAULT_PROFILES_FILE=/root/config/dds/husarnet_profile.xml)
  params+=(-v $ROOT_DIR/config/husarnet:/var/lib/husarnet)
  params+=(--net=bridge)
  params+=(--ipc=shareable)
else
  params+=(--net=host)
  params+=(--ipc=host)
  params+=(--pid=host)
fi

if [ -z "$DATASET_PATH" ]; then
  DATASET_PATH="${ROOT_DIR}/datasets/"
  echo "Dataset path was not given. Defaults to=${DATASET_PATH}"
else
  echo "Mounting ${DATASET_PATH} as dataset path"
fi


if [ -z "$RESULTS_PATH" ]; then
  RESULTS_PATH="${ROOT_DIR}/results/"
  echo "Results path was not given. Defaults to=${RESULTS_PATH}"
else
  echo "Mounting ${RESULTS_PATH} as dataset path"
fi


#echo "${params[@]}"
docker run  -it \
            --rm \
            --cap-add NET_ADMIN \
            --privileged \
            -e SLAM_SYSTEM_ID=$SLAM_SYSTEM_ID \
            -e DISPLAY=$DISP \
            -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
            -e PYTHONBUFFERED=1 \
            -e TARGET_BUILD=${TARGET_BUILD} \
            -v /etc/timezone:/etc/timezone:ro \
            -v /etc/localtime:/etc/localtime:ro \
            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
            -v $HOME/.Xauthority:/root/.Xauthority:rw \
            -v $HOME/.tmux/:/root/.tmux \
            -v $HOME/.config/:/root/.config \
            -v /run/user/1000:/run/user/1000 \
            -v $ROOT_DIR/scripts/plots:/root/traj_eval/plots \
            -v $DATASET_PATH:/root/datasets \
            -v $RESULTS_PATH:/root/results \
            -v $ROOT_DIR/config/dds:/root/config/dds \
            --mount type=bind,source=$ROOT_DIR/scripts/run_experiments.sh,target=/root/run_experiments.sh \
            --mount type=bind,source=$ROOT_DIR/scripts/process_network_files.sh,target=/root/process_network_files.sh \
            --device=/dev/bus/usb:/dev/bus/usb \
            "${params[@]}" \
            $REGISTRY/$IMAGE:$VERSION \
            bash

  #docker run  -it \
  #            --rm \
  #            --net=host \
  #            --ipc=host \
  #            --pid=host \
  #            --cap-add NET_ADMIN \
  #            --name $CONTAINER_NAME \
  #            --privileged \
  #            -e DISPLAY=docker.for.mac.host.internal:0 \
  #            -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  #            -e PYTHONBUFFERED=1 \
  #            -e TARGET_BUILD=${TARGET_BUILD} \
  #            -v /etc/timezone:/etc/timezone:ro \
  #            -v /etc/localtime:/etc/localtime:ro \
  #            -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  #            -v $HOME/.Xauthority:/root/.Xauthority \
  #            -v $HOME/.tmux/:/root/.tmux \
  #            -v $HOME/.config/:/root/.config \
  #            -v /run/user/1000:/run/user/1000 \
  #            -v $ROOT_DIR/ros_ws/:/root/colcon_ws \
  #            -v $ROOT_DIR/datasets/:/root/datasets \
  #            -v $ROOT_DIR/results/:/root/results \
  #            -v $ROOT_DIR/orbslam3/:/root/colcon_ws/src \
  #            -v $ROOT_DIR/thirdparty/ORB_SLAM3:/root/ORB_SLAM3-dev \
  #            --device=/dev/bus/usb:/dev/bus/usb \
  #            $REGISTRY/$IMAGE:$VERSION \
  #            bash

#if [ $GPU_SUPPORT == 1 ]; then
#
#  if [ -z "$CONTAINER_NAME" ]; then
#    docker run  -it \
#                --rm \
#                --net=host \
#                --cap-add NET_ADMIN \
#                --privileged \
#                --gpus all \
#                -e DISPLAY=$DISPLAY \
#                -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#                -e PYTHONBUFFERED=1 \
#                -e TARGET_BUILD=${TARGET_BUILD} \
#                -v /etc/timezone:/etc/timezone:ro \
#                -v /etc/localtime:/etc/localtime:ro \
#                -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
#                -v $HOME/.Xauthority:/root/.Xauthority:rw \
#                -v $HOME/.tmux/:/root/.tmux \
#                -v $HOME/.config/:/root/.config \
#                -v /run/user/1000:/run/user/1000 \
#                -v $ROOT_DIR/ros_ws/:/root/colcon_ws \
#                -v $ROOT_DIR/datasets/:/root/datasets \
#                -v $ROOT_DIR/results/:/root/results \
#                -v $ROOT_DIR/orbslam3/:/root/colcon_ws/src \
#                -v $ROOT_DIR/thirdparty/ORB_SLAM3:/root/ORB_SLAM3-dev \
#                --device=/dev/bus/usb:/dev/bus/usb \
#                $REGISTRY/$IMAGE:$VERSION \
#                bash
#  else
#
#    docker run  -it \
#                --rm \
#                --net=host \
#                --cap-add NET_ADMIN \
#                --privileged \
#                --gpus all \
#                --name $CONTAINER_NAME \
#                -e DISPLAY=$DISPLAY \
#                -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
#                -e PYTHONBUFFERED=1 \
#                -e TARGET_BUILD=${TARGET_BUILD} \
#                -v /etc/timezone:/etc/timezone:ro \
#                -v /etc/localtime:/etc/localtime:ro \
#                -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
#                -v $HOME/.Xauthority:/root/.Xauthority:rw \
#                -v $HOME/.tmux/:/root/.tmux \
#                -v $HOME/.config/:/root/.config \
#                -v /run/user/1000:/run/user/1000 \
#                -v $ROOT_DIR/ros_ws/:/root/colcon_ws \
#                -v $ROOT_DIR/datasets/:/root/datasets \
#                -v $ROOT_DIR/results/:/root/results \
#                -v $ROOT_DIR/orbslam3/:/root/colcon_ws/src \
#                -v $ROOT_DIR/thirdparty/ORB_SLAM3:/root/ORB_SLAM3-dev \
#                --device=/dev/bus/usb:/dev/bus/usb \
#                $REGISTRY/$IMAGE:$VERSION \
#                bash
#  fi
#else
#
#fi

