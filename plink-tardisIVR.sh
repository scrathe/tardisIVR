#!/bin/bash

# read PLINK.md for setup

# the $win_path directories defined below are the only locations right-click-to-plink works
# improve this

# ~/.sabnzbd   # tidle ~/ home directory alias doesn't seem to work
# use full path to script instead
script="/home/elvie/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh"

if [[ "$2" == "movies" ]]; then
    # tag / atomicparsley only
    if [[ "$3" == "tag" ]]; then
        options="x x x movies x x tag"
    else
    # handbrake + atomicparsley
        options="x x x movies x x"
    fi
elif [[ "$2" == "tv" ]]; then
    if [[ "$3" == "tag" ]]; then
        options="x x x tv x x tag"
    else
        options="x x x tv x x"
    fi
else
   echo "!!! Error, '\$2' not specified."
   exit 1
fi

# remap your windows to linux storage paths
# $1 = argument passed from windows/plink-tardisIVR.bat script
dir="$(sed 's|^X:|/media/tardis-x|; s|\\|/|g' <<< "$1")"

# send command to tardisIVRvideo.sh
echo "'$script' '$dir' '$options'"
"$script" "$dir" $options
