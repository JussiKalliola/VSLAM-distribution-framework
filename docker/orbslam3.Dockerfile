FROM jussikalliola/nano-ros2-orbslam3-base:amd64 AS amd64_base
FROM jussikalliola/nano-ros2-orbslam3-base:arm64 AS arm64_base

FROM ${TARGETARCH}_base AS orbslam3

SHELL ["/bin/bash", "-c"]

ENV ORB_SLAM3_DIR=/root/ORB_SLAM3-dev

COPY thirdparty/ORB_SLAM3 /root/ORB_SLAM3-dev
RUN cd /root/ORB_SLAM3-dev && ./build.sh \
    && cd /root/ORB_SLAM3-dev/Thirdparty/Sophus/build \
    && make install
