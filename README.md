# Self-Organizing Edge Computing Distribution Framework for Visual SLAM 

Official implementation of the RA-L paper "Self-Organizing Edge Computing Distribution Framework for Visual SLAM".

If you use parts of this work, or otherwise take inspiration from it, please consider citing the thesis:
```
@ARTICLE{11458821,
  author={Kalliola, Jussi and Suomela, Lauri and Moreschini, Sergio and Hästbacka, David},
  journal={IEEE Robotics and Automation Letters}, 
  title={Self-Organizing Edge Computing Distribution Framework for Visual SLAM}, 
  year={2026},
  volume={11},
  number={5},
  pages={6328-6335},
  doi={10.1109/LRA.2026.3679267}
}
```

---


## System requirements

TBD.


## Pull the repository and build docker container

Pull repository
```
git clone https://github.com/JussiKalliola/VSLAM-distribution-framework.git 
```

Build and run docker container

X86_64 architecture
```sh
cd docker


#Build base image (General ROS2 packages and other system dependencies). Not recommended if no changes are needed (changes in `base.Dockerfile`)
./build_base.sh -v amd64 -p linux/amd64 -t dev

#Build and push the ORB-SLAM3 image separately. Rebuild when ORB-SLAM3 sources or its build dependencies change.
./build_orbslam3.sh -v amd64 -p linux/amd64

#Build the ROS2/distributor runtime image from the prebuilt ORB-SLAM3 image.
./build.sh -v amd64 -p linux/amd64 -t dev

#Or run container with x86_64 version and development tag (Pulls the docker image from dockerhub)
#Tracking (Use `test` -tag if running on edge devices so it does not build the system from scratch)
./run.sh -v amd64 -t dev -n tr -m 0 -d /media/xavier/apple/root/dslam/datasets/
#Others (change container name for LC and LM if used)
./run.sh -v amd64 -t dev -n lm 
```


ARM64 architecture
```sh
cd docker

#Build base image (General ROS2 packages and other system dependencies). Not recommended if no changes are needed (changes in `base.Dockerfile`)
./build_base.sh -v arm64 -p linux/arm64 -t dev

#Build and push the ORB-SLAM3 image separately. Rebuild when ORB-SLAM3 sources or its build dependencies change.
./build_orbslam3.sh -v arm64 -p linux/arm64

#Build the ROS2/distributor runtime image from the prebuilt ORB-SLAM3 image.
./build.sh -v arm64 -p linux/arm64 -t dev

#Or run container with arm64 version and development tag (Pulls the docker image from dockerhub)
#Tracking (Use `test` -tag if running on edge devices so it does not build the system from scratch)
./run.sh -v arm64 -t dev -n tr -m 0 -d /media/xavier/apple/root/dslam/datasets/
#Others (change container name for LC and LM if used)
./run.sh -v arm64 -t dev -n lm 
```

Use the same `-v` tag for the ORB-SLAM3 and runtime image builds. If the runtime build fails, rerun `build.sh`; rerun `build_orbslam3.sh` only when ORB-SLAM3 sources or its build dependencies have changed.

In `dev` mode, the container entrypoint still rebuilds ORB-SLAM3 from the mounted source tree at startup. The separate image prevents a failed ROS2/distributor image build from discarding a successful ORB-SLAM3 image build; it does not change that development startup behavior.


##### Build parameters
- `-h`: **Help**. summary of the parameters 
- `-v`: **Version**. Docker image version build for different architectures. E.g., arm64, amd64, ...
- `-p`: **Platforms**. Same as previous. E.g., arm64, amd64, ...
- `-c`: **Use Cache**. Use cache for building the image. Reduces the build time for subsequent builds, but might cause errors.
- `-t`: **Tag**. Target build. Build process differs slightly with development/production, mainly that SLAM and other modules are prebuilt in the image. Faster for edge devices.


##### Run parameters
- `-h`: **Help**. summary of the parameters 
- `-v`: **Version**. Docker image version build for different architectures. E.g., arm64, amd64, ...
- `-t`: **Tag**. Target build. Build process differs slightly with development/production, mainly that SLAM and other modules are prebuilt in the image. Faster for edge devices.
- `-n`: **Container name**. Container name. Defaults to docker container name set automatically. 
- `-d`: **Dataset**. Mount custom dataset path to docker image (e.g., external HDD). Otherwise mounts /datasets from the project directory.
- `-m`: **Display**. DISPLAY env variable. Uses default if not set. If set, then uses localhost:10.0 

## Run experiments

#### EuRoC Monocular

Run the following commands on different devices/containers

Tracking
```sh
export SLAM_SYSTEM_ID=TR
ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/EuRoC.yaml ~/results/EuRoC/V1_03/ false KeyFrameTrajectory-tr.txt true true false camera
```

Local mapping
```sh
export SLAM_SYSTEM_ID=LM
ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/EuRoC.yaml ~/results/EuRoC/V1_03/ false KeyFrameTrajectory-lm.txt true false false
```

Loop closing
```sh
export SLAM_SYSTEM_ID=LC
ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/EuRoC.yaml ~/results/EuRoC/V1_03/ false KeyFrameTrajectory-lc.txt true false false
```

##### List of parameters:
1. ORB Vocabulary file path
2. Config file path
3. Results directory path
4. Visualization on/off [BOOLEAN]
5. Results filename 
6. Subscribe to SLAM topics [BOOLEAN]
7. Main system [BOOLEAN]
8. Integrate omnet++ network simulation [BOOLEAN]. Default: false
9. Camera ROS2 topic [STRING]. Default: /camera

```sh
ros2 run orbslam3 mono orb_path[STRING] config_path[STRING] results_dir[STRING] visualization[BOOLEAN] results_filename[STRING] subscribe[BOOLEAN] main_system[BOOLEAN] camera_topic[STRING]
```

## Datasets

#### ROS2 Bag
##### EuRoC dataset:

```sh
#Monocular - MH_01
ros2 bag play ~/datasets/EuRoC/MH_01/ --remap /cam0/image_raw:=/camera

#Monocular - V2_03
ros2 bag play ~/datasets/EuRoC/V1_03/ --remap /cam0/image_raw:=/camera



#Stereo-inertial
ros2 bag play ~/datasets/EuRoC/MH_01/ --remap /cam0/image_raw:=/camera/left /cam1/image_raw:=/camera/right /imu0:=/imu
```

## Evaluate

Activate python virtual environment 
```sh
cd ~/ && source ~/traj_eval/bin/activate
```

Compare estimated trajectory with ground truth visually
```sh
# Full trajectory: Alignment and scaling with GT data (With visualization)
evo_traj tum ~/results/EuRoC/MH_01/monocular/Trajectory-TR.txt --ref ~/datasets/EuRoC/MH_01/gt.txt -p -as

# KeyFrame trajectories: Alignment and scaling with GT data (With visualization)
evo_traj tum ~/results/EuRoC/MH_01/monocular/KeyFrameTrajectory* --ref ~/results/EuRoC/MH_01/monocular/gt.txt -p -as
```

System performance plots
```sh
cd traj_eval/plots

python3 plot_results.py -category EuRoC -datasets V1_03 -devices 0 -plot_slam true
```


Metrics saved to CSV file from all datasets (SLAM, CPU utilization)
```sh
cd traj_eval/plots
python3 calculate_metrics.py -results ~/results/f_nuc_single_EuRoC/ -gt ~/datasets/EuRoC/ -output ~/results/xavier_single_EuRoC_results.csv
```

More information about SLAM metrics from the documentation in [github by Michael Grupp](https://github.com/MichaelGrupp/evo/wiki/evo_traj)

---

[Dockerhub](https://hub.docker.com/repository/docker/jussikalliola/nano-ros2-orbslam3/general)
