
# https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

# No cuda
ARG ORB_SLAM3_IMAGE=jussikalliola/nano-ros2-orbslam3-orb:latest
FROM ${ORB_SLAM3_IMAGE} AS dev

ARG TARGET_BUILD

SHELL ["/bin/bash", "-c"] 

ENV TARGET_BUILD=$TARGET_BUILD
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

ENV RMW_FASTRTPS_PUBLICATION_MODE=SYNCHRONOUS
#ENV FASTDDS_BUILTIN_TRANSPORTS=LARGE_DATA?max_msg_size=5MB&sockets_size=10MB&non_blocking=true&tcp_negotiation_timeout=100
#sysctl net.ipv4.ipfrag_high_thresh=134217728 && sysctl net.ipv4.ipfrag_time=3

#ENV FASTDDS_STATISTICS="HISTORY_LATENCY_TOPIC;NETWORK_LATENCY_TOPIC;\
#PUBLICATION_THROUGHPUT_TOPIC;SUBSCRIPTION_THROUGHPUT_TOPIC;RTPS_SENT_TOPIC;\
#RTPS_LOST_TOPIC;HEARTBEAT_COUNT_TOPIC;ACKNACK_COUNT_TOPIC;NACKFRAG_COUNT_TOPIC;\
#GAP_COUNT_TOPIC;DATA_COUNT_TOPIC;RESENT_DATAS_TOPIC;SAMPLE_DATAS_TOPIC;\
#PDP_PACKETS_TOPIC;EDP_PACKETS_TOPIC;DISCOVERY_TOPIC;PHYSICAL_DATA_TOPIC;\
#MONITOR_SERVICE_TOPIC"
#
#RUN cd /opt/ros/humble \
#    && colcon build --merge-install --packages-select fastrtps --cmake-args -DFASTDDS_STATISTICS=ON \
#    && source ./install/setup.bash


ENV ORB_SLAM3_DIR=/root/ORB_SLAM3-dev

RUN mkdir -p /root/colcon_ws/src/orbslam3_interfaces \
    && mkdir -p /root/colcon_ws/src/orbslam3_ros2 \
    && mkdir -p /root/colcon_ws/build \
    && mkdir -p /root/colcon_ws/log \
    && mkdir -p /root/colcon_ws/install

RUN ls /root/colcon_ws
#COPY ros_ws /root/colcon_ws
#COPY ros_ws/build /root/colcon_ws/build
#COPY ros_ws/install /root/colcon_ws/install
#COPY ros_ws/log /root/colcon_ws/log
COPY orbslam3/omnetpp_interfaces /root/colcon_ws/src/omnetpp_interfaces
COPY orbslam3/orbslam3_ros2 /root/colcon_ws/src/orbslam3_ros2
COPY orbslam3/orbslam3_interfaces /root/colcon_ws/src/orbslam3_interfaces
#COPY ros_ws/build /root/colcon_ws/build
#COPY ros_ws/install /root/colcon_ws/install
#COPY ros_ws/log /root/colcon_ws/log

RUN cd /root/colcon_ws \
    && source $ROS_ROOT/install/setup.bash \
    && MAKEFLAGS="-j 1" colcon build --symlink-install

RUN apt update && apt install -y tcpdump gdb

# HUSARNET
RUN apt-get update -y && apt-get install -y curl
RUN curl -s https://install.husarnet.com/install.sh | bash

#RUN wget -qO- https://raw.githubusercontent.com/luxonis/depthai-ros/main/install_dependencies.sh | bash
#RUN mkdir -p /root/dai_ws/src \
#    && cd /root/dai_ws/src \
#    && git clone --branch $ROS_DISTRO https://github.com/luxonis/depthai-ros.git \
#    && cd .. \
#    && rosdep install --from-paths src --ignore-src -r -y \
#    && source $ROS_ROOT/install/setup.bash
#RUN apt install ros-humble-vision-msgs
#RUN MAKEFLAGS="-j1 -l1" colcon build \
#    && source ./install/setup.bash



RUN mkdir -p /root/config/dds

COPY ros_entrypoint.sh /


#&& git clone https://github.com/JussiKalliola/ORB_SLAM3_ROS2.git -b refactor orbslam3_ros2 \
#&& git clone https://github.com/JussiKalliola/nano-slam-ros2.git -b refactor orbslam3 \
#&& mv ./orbslam3/orbslam3/orbslam3_interfaces ./ \
#&& rm -rf ./orbslam3 \

RUN source /root/colcon_ws/install/setup.bash


ENTRYPOINT ["/ros_entrypoint.sh"]

WORKDIR /root/colcon_ws
