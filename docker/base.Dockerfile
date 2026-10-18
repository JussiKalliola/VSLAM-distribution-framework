# https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

# No cuda
FROM ubuntu:22.04 as amd64_base

# Cuda
#FROM nvcr.io/nvidia/cudagl:11.4.2-devel-ubuntu18.04 as amd64_cuda_base
  
FROM ubuntu:22.04 as arm64_base

FROM ${TARGETARCH}_base as dev

ARG TARGET_BUILD
ARG ARCH

SHELL ["/bin/bash", "-c"] 
ENV SKIP_ROSDEP=""
ENV TARGET_BUILD=$TARGET_BUILD
ENV ARCH=$ARCH
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib/"
# https://github.com/NVIDIA-AI-IOT/ros2_jetson/blob/main/docker/DockerFile.l4tbase.ros2.foxy
# https://docs.ros.org/en/foxy/Installation/Alternatives/Ubuntu-Development-Setup.html#id9
# https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html

ENV ROS_DISTRO=humble
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3
ENV SHELL /bin/bash

ENV DEBIAN_FRONTEND=noninteractive
ENV RTI_NC_LICENSE_ACCEPTED=yes

# change the locale from POSIX to UTF-8
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8


RUN apt update \
  && apt upgrade -y \
  && apt install -y \
    software-properties-common \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    software-properties-common \
    terminator \
    build-essential \
    cmake \
    git \
    python3 \
    libpython3-dev \
    xorg-dev \
    libusb-1.0-0-dev \
    libxinerama-dev \
    python3 \
    python3-dev \
    libgtk2.0-dev \
    pkg-config \
    #libpython3.8-dev \
    #gcc-8 g++-8 \
    tmux \
    vim \
  && rm /usr/bin/gcc /usr/bin/g++ \
  && ln -s gcc-8 /usr/bin/gcc \
  && ln -s g++-8 /usr/bin/g++ \
  && add-apt-repository universe

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN apt update && apt install -y \
  libbullet-dev \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools \
  # install some pip packages needed for testing
  && python3 -m pip install -U \
    argcomplete \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    pytest \
    # install Fast-RTPS dependencies
  && apt install --no-install-recommends -y \
    libasio-dev \
    libtinyxml2-dev \
    # install Cyclone DDS dependencies
    libcunit1-dev
  
RUN apt install -y \
  python3-colcon-common-extensions \
  python3-numpy \
  python3-rosdep \
  python3-vcstool \
  python3-rosinstall-generator \ 
  libflann-dev \
  #libvtk6-dev \
  #libvtk6-qt-dev \
  libpcap-dev \
  libboost-all-dev \
  #libboost-filesystem-dev \
  #libboost-iostreams-dev \
  #libboost-system-dev \
  #libboost-date-time-dev \
  unzip \
  && python3 -m  pip install setuptools==58.2.0

# PCL 1.11 from source. PCL 1.8 from apt has some issues
# which we face with rtab_map

## Dependencies
#RUN apt install -y libflann-dev \
#  libvtk6-dev \
#  libvtk6-qt-dev \
#  libpcap-dev \
#  libboost-filesystem-dev \
#  libboost-iostreams-dev \
#  libboost-system-dev \
#  libboost-date-time-dev

## Original PCL installation
#RUN wget https://github.com/PointCloudLibrary/pcl/archive/refs/tags/pcl-1.11.1.tar.gz \
#  && tar xvf pcl-1.11.1.tar.gz && rm pcl-1.11.1.tar.gz \
#  && cd pcl-pcl-1.11.1 \
#  && mkdir build && cd build \
#  && cmake .. \
#  && make -j`nproc` install

# Should be Space seperated stirng
#ENV ROSDEP_SKIP_PACKAGES="libpcl-dev"

RUN apt-get update && apt update \
    && apt install -y freeglut3-dev \
    libboost-all-dev \
    #libunwind-dev \
    #libgstreamer1.0-dev \
    #libgstreamer-plugins-base1.0-dev \
    #libgstreamer-plugins-bad1.0-dev \
    #gstreamer1.0-plugins-base \
    #gstreamer1.0-plugins-good \
    #gstreamer1.0-plugins-bad \
    #gstreamer1.0-plugins-ugly \
    #gstreamer1.0-libav \
    #gstreamer1.0-tools \
    #gstreamer1.0-x \
    #gstreamer1.0-alsa \
    #gstreamer1.0-gl \
    #gstreamer1.0-gtk3 \
    #gstreamer1.0-qt5 \
    #gstreamer1.0-pulseaudio \
    python3-dev \
    python2-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpython3-dev \
    libopenblas-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgl1-mesa-dev \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    libegl1-mesa-dev \
    libc++-dev \
    libglew-dev \
    libeigen3-dev \
    g++ \
    ninja-build \
    libjpeg-dev \
    libpng-dev \
    libavcodec-dev \
    libavutil-dev \
    libavformat-dev \
    libswscale-dev \
    libavdevice-dev \
    libompl-dev \
    ompl-demos \
    libeigen3-dev \
    x11-apps \
    mesa-utils \
    libhdf5-serial-dev \
    libepoxy-dev \
    libgles2-mesa-dev \
    libglfw3-dev

RUN apt-get update && apt-get install -y ninja-build
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --upgrade --no-cache-dir --verbose cmake

RUN cd /root && apt update; \
    if [ "$ARCH" == "arm64" ]; then \
    wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/gcc-8_8.4.0-3ubuntu2_arm64.deb; \
    wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/gcc-8-base_8.4.0-3ubuntu2_arm64.deb; \
    wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/libgcc-8-dev_8.4.0-3ubuntu2_arm64.deb; \
    wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/cpp-8_8.4.0-3ubuntu2_arm64.deb; \
    wget http://ports.ubuntu.com/ubuntu-ports/pool/main/i/isl/libisl22_0.22.1-1_arm64.deb; \ 
    apt install -y /root/gcc-8_8.4.0-3ubuntu2_arm64.deb /root/gcc-8-base_8.4.0-3ubuntu2_arm64.deb /root/libgcc-8-dev_8.4.0-3ubuntu2_arm64.deb /root/cpp-8_8.4.0-3ubuntu2_arm64.deb /root/libisl22_0.22.1-1_arm64.deb; \
    else \
    wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/gcc-8_8.4.0-3ubuntu2_amd64.deb; \
    wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/g/gcc-8/gcc-8-base_8.4.0-3ubuntu2_amd64.deb; \
    wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb; \
    wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/cpp-8_8.4.0-3ubuntu2_amd64.deb; \
    wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/libmpx2_8.4.0-3ubuntu2_amd64.deb; \
    wget http://mirrors.kernel.org/ubuntu/pool/main/i/isl/libisl22_0.22.1-1_amd64.deb; \
    apt install -y /root/libisl22_0.22.1-1_amd64.deb /root/libmpx2_8.4.0-3ubuntu2_amd64.deb /root/cpp-8_8.4.0-3ubuntu2_amd64.deb /root/libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb /root/gcc-8-base_8.4.0-3ubuntu2_amd64.deb /root/gcc-8_8.4.0-3ubuntu2_amd64.deb; \
    fi
    
    
RUN cd /root; \
    if [ "$ARCH" == "arm64" ]; then \
	wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/libstdc++-8-dev_8.4.0-3ubuntu2_arm64.deb; \
	wget http://ports.ubuntu.com/ubuntu-ports/pool/universe/g/gcc-8/g++-8_8.4.0-3ubuntu2_arm64.deb; \
	apt install -y /root/libstdc++-8-dev_8.4.0-3ubuntu2_arm64.deb /root/g++-8_8.4.0-3ubuntu2_arm64.deb; \
    else \
	wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/libstdc++-8-dev_8.4.0-3ubuntu2_amd64.deb; \
	wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gcc-8/g++-8_8.4.0-3ubuntu2_amd64.deb; \
	sudo apt install ./libstdc++-8-dev_8.4.0-3ubuntu2_amd64.deb ./g++-8_8.4.0-3ubuntu2_amd64.deb; \
    fi

# Install Opencv (contrib for  cuda)
RUN cd /root \
    && wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip \
    && wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/4.2.0.zip \
    && cd /root && unzip opencv_contrib.zip \
    && cd /root && unzip opencv.zip && cd opencv-4.2.0 && mkdir build && cd build \
    && cmake -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib-4.2.0/modules \
             -D CMAKE_BUILD_TYPE=Release \
             -D BUILD_opencv_python2=OFF \
             -D BUILD_opencv_python3=ON \
             -D WITH_TBB=ON \
             -D WITH_V4L=ON \
             #-D WITH_QT=ON \
             -D WITH_OPENGL=ON \
             -D WITH_EIGEN=ON .. \
             #-D WITH_GSTREAMER=ON .. \
    && make -j8 && make install


# get ROS2 code
RUN mkdir -p ${ROS_ROOT}/src \
  && cd ${ROS_ROOT} \
  && vcs import --input https://raw.githubusercontent.com/ros2/ros2/${ROS_DISTRO}/ros2.repos src

RUN echo 'export ROS_PACKAGE_PATH="${ROS_ROOT}/src"' > /setup_ROS_PACKAGE_PATH.sh \
  && echo 'for dir in ${ROS_ROOT}/src/*; do export ROS_PACKAGE_PATH="$dir:$ROS_PACKAGE_PATH"; done' >> /setup_ROS_PACKAGE_PATH.sh \
  && echo "source /setup_ROS_PACKAGE_PATH.sh >> /etc/bash.bashrc"

ENV ROSDEP_SKIP_PACKAGES="fastcdr rti-connext-dds-6.0.1 urdfdom_headers"
RUN cd ${ROS_ROOT} && source /setup_ROS_PACKAGE_PATH.sh \
  && apt upgrade -y \
  && rosdep init \
  && rosdep update \
  #&& rosinstall_generator desktop --rosdistro ${ROS_DISTRO} --deps --exclude RPP | vcs import src \
  && rosdep install --from-paths src --ignore-src -r -y --rosdistro=$ROS_DISTRO --skip-keys="$ROSDEP_SKIP_PACKAGES" 


RUN cd ${ROS_ROOT} \
  && colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release \
  &&. ${ROS_ROOT}/install/local_setup.bash \
  && echo "source $ROS_ROOT/install/setup.bash" >> /etc/bash.bashrc \
  && echo "source $ROS_ROOT/install/local_setup.bash" >> /etc/bash.bashrc \
  && TEST_PLUGINLIB_PACKAGE="${ROS_ROOT}/build/pluginlib/pluginlib_enable_plugin_testing/install/test_pluginlib__test_pluginlib/share/test_pluginlib/package.xml" && \
  sed -i '/<\/description>/a <license>BSD<\/license>' $TEST_PLUGINLIB_PACKAGE && \
  sed -i '/<\/description>/a <maintainer email="michael@openrobotics.org">Michael Carroll<\/maintainer>' $TEST_PLUGINLIB_PACKAGE && \
  cat $TEST_PLUGINLIB_PACKAGE

# To install ROS packages from source
RUN mkdir -p /root/ros2_pre_installed/src \
    && cd /root/ros2_pre_installed/src \
    && git clone -b ${ROS_DISTRO} https://github.com/ros-perception/vision_opencv.git \
    && git clone -b ${ROS_DISTRO} https://github.com/ros2/message_filters.git

RUN cd /root/ros2_pre_installed \
  && apt-get autoclean \
  && source $ROS_ROOT/install/setup.bash \
  && rosdep install --from-paths src --ignore-src -r -y --rosdistro=$ROS_DISTRO \ 
  #--skip-keys="fastcdr rti-connext-dds-6.0.1 urdfdom_headers" \
  && colcon build --merge-install --install-base "$ROS_ROOT/install" --cmake-args -DCMAKE_BUILD_TYPE=Release 



# Install python3.8 and setup virtualenvironment for trajectory evaluation using package:
# https://github.com/MichaelGrupp/evo/wiki/evo_traj
RUN mkdir ~/traj_eval && cd ~/traj_eval \
    && python3 -m pip install virtualenv \
    && virtualenv --python="/usr/bin/python3" "./" \ 
    && source ~/traj_eval/bin/activate \
    && pip install evo --upgrade --no-binary evo && deactivate


# Install Pangolin (ORB SLAM3 Pre req)
RUN cd /root \
    && git clone --recursive https://github.com/stevenlovegrove/Pangolin.git Pangolin \
    && cd Pangolin && git reset --hard a29c8a4 && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j8 && make install

#CMD ["bash"]

#WORKDIR /root/colcon_ws
