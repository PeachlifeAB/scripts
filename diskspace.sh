#!/usr/bin/awk -f
BEGIN {
    header() 
    cmd = "df -h"
    while ((cmd | getline) > 0) {
        volumePath = $NF
        if(isDesiredVolume(volumePath)) {
            volumeName = volumePath; sub(".*/", "", volumeName)
            sizeTitle = $4; sub("Gi", "Gb", sizeTitle) 
            usedPercentage = $5; sub("%", "", usedPercentage)
            freePercentage = 100 - usedPercentage
            printf "%-20s %9s %9s\n", volumeName, sprintf("%3d%%", freePercentage), sizeTitle
        }
    }
    close(cmd)
    exit
}

function isDesiredVolume(volumePath) {
    return volumePath ~ /^\/Volumes\// || volumePath == "/System/Volumes/Data"
}

function header() {
    headerRow = sprintf("%-24s %-14s", "Volume", "Available space")
    print(headerRow)
    # divider
    for(i = 1; i <= length(headerRow); i++) {
        printf "-"
    }
    print ""
}
