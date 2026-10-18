#!/bin/bash
#set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Usage: $0 <PATH> <CATEGORY[EuRoC,TUM,OAKD]> <FILENAME>"
  exit 1
fi

FILENAME="$3"
CATEGORY="$2"
BASE_PATH="$1"
#CATEGORY="$2"

# Home network, change these for OAKD

TR_IP="192.168.0.118"
LC_IP="192.168.0.226"

if [[ "$BASE_PATH" == *room1-10* || "$BASE_PATH" == *room1-6* || \
      "$BASE_PATH" == *room4-1*  || "$BASE_PATH" == *room4-10* || \
      "$BASE_PATH" == *room4-7*  || "$BASE_PATH" == *room4-8* ]]; then
    LM_IP="192.168.0.221"
else
    LM_IP="192.168.0.222"
fi

BASE_DIR=$BASE_PATH/$CATEGORY
OUTPUT_CSV_FILE=$BASE_PATH/$FILENAME

# Write headers
echo "dataset,idx,TR_Total,LM_Total,LC_Total,TR_to_LM,TR_to_LC,LM_to_TR,LM_to_LC,LC_to_TR,LC_to_LM" > "$OUTPUT_CSV_FILE"

# Loop through immediate subfolders only
for subdir in  ${BASE_DIR}/*/; do
  echo "$subdir"
  # Skip if no subdirectories exist
  [ -d "$subdir" ] || continue

  dataset_base=$(basename "$subdir") 
  dataset_name="${dataset_base%-*}"
  dataset_idx="${dataset_base##*-}"
  vals=($dataset_name $dataset_idx "" "" "" "" "" "" "" "" "")

  echo "Processing subfolder: $subdir"
  # Loop through predefined folders
  for folder in TR LM LC; do
    target=${subdir}monocular/${folder}/

    # Check if the folder exists (optional, remove if you always expect them)
    if [ -d $target ]; then
      echo "  Found: $target"
      PCAP="${target}/${folder}_dump.pcap" 

      if [[ "$folder" == "TR" ]]; then
        IP1=$TR_IP
        IP2=$LM_IP
        IP3=$LC_IP
      elif [[ "$folder" == "LM" ]]; then
        IP1=$LM_IP
        IP2=$TR_IP
        IP3=$LC_IP
      elif [[ "$folder" == "LC" ]]; then
        IP1=$LC_IP
        IP2=$TR_IP
        IP3=$LM_IP
      fi

      # Duration in seconds as a plain number
      DURATION=$(tshark -n -o name_resolve:FALSE -r "$PCAP" -q -z io,stat,0 \
          | awk -F': *' '/Duration/ {gsub(",",".",$2); print $2+0; exit}')
      echo "after duration"

      echo $DURATION
      TSHARK_BASE=(tshark -n -o name_resolve:FALSE -r "$PCAP")

      # Totals (bytes)
      # For overall bandwidth, frame.len reflects L2 size; for IP-only payload, use ip.len instead.
      TOTAL_BYTES=$("${TSHARK_BASE[@]}" -T fields -e frame.len | awk '{sum+=$1} END{print sum+0}')
      TO2_BYTES=$("${TSHARK_BASE[@]}" -Y "ip.src==$IP1 && ip.dst==$IP2" -T fields -e ip.len | awk '{sum+=$1} END{print sum+0}')
      TO3_BYTES=$("${TSHARK_BASE[@]}" -Y "ip.src==$IP1 && ip.dst==$IP3" -T fields -e ip.len | awk '{sum+=$1} END{print sum+0}')
      TO23_BYTES=$("${TSHARK_BASE[@]}" -Y "ip.src==$IP1 && (ip.dst==$IP2 || ip.dst==$IP3)" -T fields -e ip.len | awk '{sum+=$1} END{print sum+0}')

      # Average throughput (Mbps)
      TOTAL_Mbps=$(awk -v b="$TOTAL_BYTES" -v d="$DURATION" 'BEGIN{printf((d>0)? "%.3f":"0", (b*8)/(d*1e6))}')
      TO2_Mbps=$(awk -v b="$TO2_BYTES" -v d="$DURATION" 'BEGIN{printf((d>0)? "%.3f":"0", (b*8)/(d*1e6))}')
      TO3_Mbps=$(awk -v b="$TO3_BYTES" -v d="$DURATION" 'BEGIN{printf((d>0)? "%.3f":"0", (b*8)/(d*1e6))}')
      TO23_Mbps=$(awk -v b="$TO23_BYTES" -v d="$DURATION" 'BEGIN{printf((d>0)? "%.3f":"0", (b*8)/(d*1e6))}')

      echo "$CATEGORY: $subdir"
      #echo "File: $PCAP"
      echo "Duration (s): $DURATION"
      echo
      echo "=== Overall (all traffic) ==="
      echo "Total bytes (L2): $TOTAL_BYTES"
      echo "Avg bandwidth:    $TOTAL_Mbps Mbps"
      echo
      echo "=== From $IP1 → $IP2 ==="
      echo "Bytes (IP payload): $TO2_BYTES"
      echo "Avg throughput:     $TO2_Mbps Mbps"
      echo
      echo "=== From $IP1 → $IP3 ==="
      echo "Bytes (IP payload): $TO3_BYTES"
      echo "Avg throughput:     $TO3_Mbps Mbps"
      echo
      echo "=== From $IP1 → ($IP2 OR $IP3) ==="
      echo "Bytes (IP payload): $TO23_BYTES"
      echo "Avg throughput:     $TO23_Mbps Mbps"

      if [[ "$folder" == "TR" ]]; then
        vals[2]=$TOTAL_Mbps
        vals[5]=$TO2_Mbps
        vals[6]=$TO3_Mbps
      elif [[ "$folder" == "LM" ]]; then
        vals[3]=$TOTAL_Mbps
        vals[7]=$TO2_Mbps
        vals[8]=$TO3_Mbps
      elif [[ "$folder" == "LC" ]]; then
        vals[4]=$TOTAL_Mbps
        vals[9]=$TO2_Mbps
        vals[10]=$TO3_Mbps
      fi


    else
      echo "  Missing: $target"
    fi
  done
  (IFS=,; echo "${vals[*]}") >> "$OUTPUT_CSV_FILE"
done

#PCAP="$1"
#IP1="$2"
#IP2="$3"
#IP3="$4"



