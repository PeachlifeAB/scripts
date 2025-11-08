#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi
echo "Performing read and write test for volumes defined in this script. Please wait..."
for volume in /Volumes/*; do
    if [ -d "$volume" ] && [[ "$volume" != "/Volumes/Macintosh HD" ]] && [[ "$volume" != "/Volumes/X5PRO" ]]; then
        echo "$volume"
        
        # Write speed test
        dd_output=$(dd if=/dev/zero of="$volume/testfile" bs=1024k count=1024 oflag=direct 2>&1)
        write_speed=$(echo "$dd_output" | grep 'bytes transferred' | awk -F'[()]' '{print $2}' | awk '{print $1}')
        if [[ $write_speed =~ ^[0-9]+$ ]]; then
            write_speed_mb=$(echo "scale=2; $write_speed/1024/1024" | bc)
            echo "Write: $write_speed_mb MB/s"
        fi
        
        # Read speed test
        dd_output=$(dd if="$volume/testfile" of=/dev/null bs=1024k 2>&1)
        read_speed=$(echo "$dd_output" | grep 'bytes transferred' | awk -F'[()]' '{print $2}' | awk '{print $1}')
        if [[ $read_speed =~ ^[0-9]+$ ]]; then
            read_speed_mb=$(echo "scale=2; $read_speed/1024/1024" | bc)
            echo "Read: $read_speed_mb MB/s"
        fi

        # Clean up
        rm "$volume/testfile"
        echo ""
    fi
done
