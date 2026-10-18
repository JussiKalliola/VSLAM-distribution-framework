function download_tum_dataset() {
  if [ -e "$TUM_DIR/$1" ]; then
    echo "The path $TUM_DIR/$1 already exists, skipping..."
  else
    DATASET="$1"
    #if [[ "room1" == *"$1"* ]]; then
    cd $TUM_DIR && wget -c http://vision.in.tum.de/tumvi/calibrated/512_16/dataset-${DATASET}_512_16.bag
    #if [ $? -ne 0 ]; then 
    #  rm -f ./dataset-${DATASET}_512_16.bag
    #  echo "Cant find download from http://vision.in.tum.de/tumvi/calibrated/512_16/dataset-${DATASET}_512_16.bag, skipping..."
    #else
    convert_rosbag_to_ros2 "./dataset-${DATASET}_512_16.bag" "./${DATASET}"
    mv dataset-${DATASET}_512_16.bag ./${DATASET} #&& mv ${DATASET}/dataset-${DATASET}_512_16.bag ${DATASET}/${DATASET}.bag
    #fi
  fi
}

function convert_rosbag_to_ros2() {
  rosbags-convert --src $1 --dst $2
}

function download_euroc_dataset() {
  if [ -e "$EUROC_DIR/$1" ]; then
    echo "The path $EUROC_DIR/$1 already exists, skipping..."
  else
  
    if [ "$1" == "MH_01" ]; then
      #mkdir -p $EUROC_DIR
      cd $EUROC_DIR && wget -O MH_01.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.bag
      convert_rosbag_to_ros2 "./MH_01.bag" "./MH_01"
      mv MH_01.bag ./MH_01 
    elif [ "$1" == "MH_02" ]; then
      cd $EUROC_DIR && wget -O MH_02.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_02_easy/MH_02_easy.bag
      convert_rosbag_to_ros2 "./MH_02.bag" "./MH_02"
      mv MH_02.bag ./MH_02 
    elif [ "$1" == "MH_03" ]; then
      cd $EUROC_DIR && wget -O MH_03.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_03_medium/MH_03_medium.bag
      convert_rosbag_to_ros2 "./MH_03.bag" "./MH_03"
      mv MH_03.bag ./MH_03 
    elif [ "$1" == "MH_04" ]; then
      cd $EUROC_DIR && wget -O MH_04.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_04_difficult/MH_04_difficult.bag
      convert_rosbag_to_ros2 "./MH_04.bag" "./MH_04"
      mv MH_04.bag ./MH_04 
    elif [ "$1" == "MH_05" ]; then
      cd $EUROC_DIR && wget -O MH_05.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_05_difficult/MH_05_difficult.bag
      convert_rosbag_to_ros2 "./MH_05.bag" "./MH_05"
      mv MH_05.bag ./MH_05 
    # V1
    elif [ "$1" == "V1_01" ]; then
      cd $EUROC_DIR && wget -O V1_01.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room1/V1_01_easy/V1_01_easy.bag
      convert_rosbag_to_ros2 "./V1_01.bag" "./V1_01"
      mv V1_01.bag ./V1_01 
    elif [ "$1" == "V1_02" ]; then
      cd $EUROC_DIR && wget -O V1_02.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room1/V1_02_medium/V1_02_medium.bag
      convert_rosbag_to_ros2 "./V1_02.bag" "./V1_02"
      mv V1_02.bag ./V1_02 
    elif [ "$1" == "V1_03" ]; then
      cd $EUROC_DIR && wget -O V1_03.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room1/V1_03_difficult/V1_03_difficult.bag
      convert_rosbag_to_ros2 "./V1_03.bag" "./V1_03"
      mv V1_03.bag ./V1_03 
    # V2
    elif [ "$1" == "V2_01" ]; then
      cd $EUROC_DIR && wget -O V2_01.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room2/V2_01_easy/V2_01_easy.bag
      convert_rosbag_to_ros2 "./V2_01.bag" "./V2_01"
      mv V2_01.bag ./V2_01 
    elif [ "$1" == "V2_02" ]; then
      cd $EUROC_DIR && wget -O V2_02.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room2/V2_02_medium/V2_02_medium.bag
      convert_rosbag_to_ros2 "./V2_02.bag" "./V2_02"
      mv V2_02.bag ./V2_02 
    elif [ "$1" == "V2_03" ]; then
      cd $EUROC_DIR && wget -O V2_03.bag -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room2/V2_03_difficult/V2_03_difficult.bag
      convert_rosbag_to_ros2 "./V2_03.bag" "./V2_03"
      mv V2_03.bag ./V2_03 
    # V2
    fi

  fi  
}

# define a registry to push the images to
ROOT_DIR="$PWD"
DATASET_DIR="$ROOT_DIR/datasets"
EUROC_DIR="$DATASET_DIR/EuRoC"
TUM_DIR="$DATASET_DIR/TUM"
ROS_VERSION="2"

while getopts e:t:d: flag
do
    case "${flag}" in
        e) EUROC_LIST=${OPTARG};;
        t) TUM_LIST=${OPTARG};;
        #r) ROS_VERSION=${OPTARG};;
        d) DATASET_SAVE_PATH=${OPTARG};;
    esac
done


## Check if gdown is installed
#if [ python3 -c "import gdown" &> /dev/null ]; then
#    echo "gdown is already installed."
#else
#    # Install gdown using pip
#    echo "Installing gdown..."
#    sudo pip3 install gdown && sudo pip install gdown
#fi


if [[ -n ${TUM_LIST} ]]; then 
    if [ python3 -c "import rosbags" &> /dev/null ]; then
        echo "rosbags is already installed."
    else
        echo "Installing rosbags..."
        sudo pip3 install rosbags
    
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
          echo "Rosbags installed successfully."
        else
          echo "Failed to install rosbags, Python >3.8 required. Exitting..."
          exit 1
        fi
    fi

fi


if [ -z $DATASET_SAVE_PATH ]; then
  echo "Dataset path was not given. Using default paths: ${EUROC_DIR} and ${TUM_DIR}"

  if [ ! -d $EUROC_DIR ]; then
    echo "Directory for EuRoC dataset not exists, creating it to path ${EUROC_DIR}..."
    mkdir -p $EUROC_DIR
  fi

  if [ ! -d $TUM_DIR ]; then
    echo "Directory for TUM dataset not exists, creating it to path ${TUM_DIR}..."
    mkdir -p $TUM_DIR
  fi
else
  echo "Using given path: ${DATASET_SAVE_PATH}"
  TUM_DIR="${DATASET_SAVE_PATH}/TUM"
  EUROC_DIR="${DATASET_SAVE_PATH}/EuRoC"
  
  if [ ! -d $EUROC_DIR ]; then
    echo "Directory for EuRoC dataset not exists, creating it to path ${EUROC_DIR}..."
    mkdir -p $EUROC_DIR
  fi

  if [ ! -d $TUM_DIR ]; then
    echo "Directory for TUM dataset not exists, creating it to path ${TUM_DIR}..."
    mkdir -p $TUM_DIR
  fi
fi




if [ "${EUROC_LIST}" == "all" ]; 
then
  echo "Downloading all EuRoC datasets..."
  EUROC_LIST="MH_01,MH_02,MH_03,MH_04,MH_05,V1_01,V1_02,V1_03,V2_01,V2_02,V2_03"
fi


IFS=',' read -ra ADDR <<< "$EUROC_LIST"
for i in "${ADDR[@]}"; do
  download_euroc_dataset $i
done

if [ "$TUM_LIST" == "all" ]; then
  echo "Downloading all TUM datasets..."
  TUM_LIST="room1,room2,room3,room4,room5,room6,corridor1,corridor2,corridor3,corridor4,corridor5,outdoors1,outdoors2,outdoors3,outdoors4,outdoors5,outdoors6,outdoors7,outdoors8,magistrale1,magistrale2,magistrale3,magirstrale4,magistrale5,magistrale6"
fi

IFS=',' read -ra ADDR <<< "$TUM_LIST"
for i in "${ADDR[@]}"; do
  download_tum_dataset $i
done






