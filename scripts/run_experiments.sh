CATEGORY=
MODE=
NAME=
SLAM_SYSTEM_ID=
CONFIG_FILE=
SUB_TO_CAM=true
TRACK_NETWORK=false
NETWORK_FILTER=
NETWORK_INTERFACE=
ITERATIONS=1
MAX_ITERATIONS=3

while getopts m:c:n:s:i:t: flag
do
    case "${flag}" in
        m) MODE=${OPTARG};;
        c) CATEGORY=${OPTARG};;
        n) NAME=${OPTARG};;
        s) SLAM_SYSTEM_ID=${OPTARG};;
        i) MAX_ITERATIONS=${OPTARG};;
        t) TRACK_NETWORK=${OPTARG};;
        #i) NETWORK_INTERFACE=${OPTARG};;
    esac
done

MAX_ITERATIONS=$MAX_ITERATIONS+1

# Check version
if [ -z "${CATEGORY}" ]; 
then
  echo "Category is required."
  exit
else
  if [[ "${CATEGORY}" == "TUM" ]];
  then
    CONFIG_FILE=TUM-VI.yaml
  elif [[ "${CATEGORY}" == "EuRoC" ]];
  then
    CONFIG_FILE=EuRoC.yaml
  elif [[ "${CATEGORY}" == "OAKD" ]];
  then
    CONFIG_FILE=oakd-mini.yaml
  else
    echo "Only TUM and EuRoC dataset categories are accepted."
    exit
  fi
fi

if [ -z "${NAME}" ]; 
then
  echo "Dataset name is required."
  exit
fi


# SLAM ID
if [ -z "${SLAM_SYSTEM_ID}" ]; 
then
  echo "SLAM_SYSTEM_ID is required."
  exit
fi

# Check mode
if [ -z "${MODE}" ]; 
then
  echo "MODE is required. Options dslam single, multi, or original."
  exit
fi

echo "Dataset category: $CATEGORY";
echo "Dataset name: $NAME";
echo "SLAM ID: $SLAM_SYSTEM_ID";
echo "MODE: $MODE";





if [[ "$MODE" == "single" || "$MODE" == "original" ]]; then

    echo "Start experiments with $MODE config.";
    while (( $ITERATIONS <= $MAX_ITERATIONS )) ;
    do
      if [ -e "/root/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/" ]; then
        echo "Folder=~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/ exists, move to the next one."


        #read -p "Do you want to override directory? y/n" override_dir
        #if [[ "${override_dir}" == "y" ]]; 
        #then
        #  rm -rf ~/results/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/
        #  break
        #fi


        if (( $ITERATIONS == $MAX_ITERATIONS ));
        then
          echo "All tries up to max=$MAX_ITERATIONS exists. Delete previous folders or increase MAX_ITERATIONS with -i argument."
          break
        fi


        ITERATIONS=$((ITERATIONS + 1))
      else
        if (( $ITERATIONS == $MAX_ITERATIONS ));
        then
          echo "All tries up to max=$MAX_ITERATIONS exists. Delete previous folders or increase MAX_ITERATIONS with -i argument."
          break
        fi
        mkdir -p ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/


        ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/$CONFIG_FILE ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/ false KeyFrameTrajectory-$SLAM_SYSTEM_ID.txt true $SUB_TO_CAM & 
        #read -p "Start bag play by pressing any key." start_play
        sleep 25
        ros2 bag play ~/datasets/$CATEGORY/$NAME/ --topics '/cam0/image_raw' --remap /cam0/image_raw:=/camera --read-ahead-queue-size 100 
        ros2 topic pub /destroy std_msgs/Bool 'data: true' -1
        sleep 10
        ITERATIONS=$((ITERATIONS + 1))
      fi

    done

    #mkdir -p ~/results/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/




elif [[ "${MODE}" == "multi" ]];
then
    if [[ "${SLAM_SYSTEM_ID}" == "TR" ]];
    then
      SUB_TO_CAM=true
      NETWORK_INTERFACE=wlan0
      #IP at home 192.168.0.118
      NETWORK_FILTER="dst 192.168.0.222 or dst 192.168.0.226 or src 192.168.0.222 or src 192.168.0.226"
      #NETWORK_FILTER="dst 192.168.0.151 or dst 192.168.0.227 or src 192.168.0.151 or src 192.168.0.227"
      #NETWORK_FILTER="dst 192.168.0.226 or dst 192.168.0.151 or src 192.168.0.151 or src 192.168.0.226"
    elif [[ "${SLAM_SYSTEM_ID}" == "LM" ]];
    then
      SUB_TO_CAM=false
      NETWORK_INTERFACE=eth0
      #IP at home 192.168.0.222
      NETWORK_FILTER="dst 192.168.0.118 or dst 192.168.0.226 or src 192.168.0.118 or src 192.168.0.226"
      #NETWORK_FILTER="dst 192.168.0.173 or dst 192.168.0.151 or src 192.168.0.173 or src 192.168.0.151"
      #NETWORK_FILTER="dst 192.168.0.118 or dst 192.168.0.151 or src 192.168.0.151 or src 192.168.0.118"
    elif [[ "${SLAM_SYSTEM_ID}" == "LC" ]];
    then
      SUB_TO_CAM=false
      NETWORK_INTERFACE=wlan0
      # IP at home 192.168.0.226
      NETWORK_FILTER="dst 192.168.0.118 or dst 192.168.0.226 or src 192.168.0.226 or src 192.168.0.118"
      #NETWORK_FILTER="dst 192.168.0.173 or dst 192.168.0.227 or src 192.168.0.227 or src 192.168.0.173"
      #NETWORK_FILTER="dst 192.168.0.118 or dst 192.168.0.226 or src 192.168.0.226 or src 192.168.0.118"
    fi






    while (( $ITERATIONS <= $MAX_ITERATIONS )) ;
    do
      if [ -e "/root/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/" ]; then
        echo "Folder=~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/ exists, move to the next one."


        #read -p "Do you want to override directory? y/n" override_dir
        #if [[ "${override_dir}" == "y" ]]; 
        #then
        #  rm -rf ~/results/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/
        #  break
        #fi


        if (( $ITERATIONS == $MAX_ITERATIONS ));
        then
          echo "All tries up to max=$MAX_ITERATIONS exists. Delete previous folders or increase MAX_ITERATIONS with -i argument."
          break
        fi


        ITERATIONS=$((ITERATIONS + 1))
      else
        if (( $ITERATIONS == $MAX_ITERATIONS ));
        then
          echo "All tries up to max=$MAX_ITERATIONS exists. Delete previous folders or increase MAX_ITERATIONS with -i argument."
          break
        fi
        mkdir -p ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/







        if [[ "${SLAM_SYSTEM_ID}" == "TR" ]]; 
        then
	    
            if [[ "${TRACK_NETWORK}" == "true" ]]; 
            then
              tcpdump -i any $NETWORK_FILTER -w ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/${SLAM_SYSTEM_ID}_dump.pcap -Z root &
              pid_tcp=$! 
            fi
            
	          ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/$CONFIG_FILE ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/ false KeyFrameTrajectory-$SLAM_SYSTEM_ID.txt true $SUB_TO_CAM false /camera &
            sleep 20 


            # Initialize counter
            count=0
      	    target=3

            echo "Subscribing to /workers topic..."

            # Subscribe and process messages until count >= 3
            ros2 topic echo /worker |
            while read -r line; do
              if [[ "$line" == "---" ]]; then
                  ((count++))
                    echo "Received message #$count"
                  if (( count >= target )); then
                    # Stop only this ros2 echo process
                    pkill -P $$ ros2
                          break
                  fi
            fi
            done


            ros2 bag play ~/datasets/$CATEGORY/$NAME/ --topics '/cam0/image_raw' --remap /cam0/image_raw:=/camera --read-ahead-queue-size 100 
	    sleep 2
            ros2 topic pub /destroy std_msgs/Bool 'data: true' -1 -w 0
            
            if [[ "${TRACK_NETWORK}" == "true" ]]; 
            then
              # Stop tcpdump cleanly
              kill -SIGINT "$pid_tcp"

              # Wait for it to finish writing file
              wait "$pid_tcp"
            fi


            sleep 5


            echo ""
            echo ""
            echo "---------- END OF AN EXPERIMENT=$NAME-$ITERATIONS --------------"
            echo ""
            echo ""
            
            ITERATIONS=$((ITERATIONS + 1))

      	    sleep 5


            ##/oak/rgb/image_rect & 
            #read -p "Start bag play by pressing any key." start_play
            #ros2 bag record -o ~/datasets/$CATEGORY/$NAME /oak/rgb/image_rect
            ##ros2 bag play ~/datasets/$CATEGORY/$NAME/ --remap /cam0/image_raw:=/camera
        else
          if [[ "${TRACK_NETWORK}" == "true" ]]; 
          then
            tcpdump -i any $NETWORK_FILTER -w ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/monocular/$SLAM_SYSTEM_ID/${SLAM_SYSTEM_ID}_dump.pcap -Z root &
            pid_tcp=$! 
          fi
    
          ros2 run orbslam3 mono ~/ORB_SLAM3-dev/Vocabulary/ORBvoc.txt ~/colcon_ws/src/orbslam3_ros2/config/monocular/$CONFIG_FILE ~/results/$MODE/$CATEGORY/$NAME-$ITERATIONS/ false KeyFrameTrajectory-$SLAM_SYSTEM_ID.txt true $SUB_TO_CAM false

          sleep 2
                
          ros2 topic pub /destroy std_msgs/Bool 'data: true' -1 -w 0
          
          if [[ "${TRACK_NETWORK}" == "true" ]]; 
          then
            # Stop tcpdump cleanly
            kill -SIGINT "$pid_tcp"

            # Wait for it to finish writing file
            wait "$pid_tcp"
          fi
          
          sleep 5
          
          echo ""
          echo ""
          echo "---------- END OF AN EXPERIMENT=$NAME-$ITERATIONS --------------"
          echo ""
          echo ""
          
          ITERATIONS=$((ITERATIONS + 1))
          
          sleep 5
        fi
      fi
    done
fi






read -p "ROS BAG DONE. PRESS ENTER TO QUIT." quit_play
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
