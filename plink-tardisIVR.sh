#!/bin/bash

script="/home/elvie/.sabnzbd/scripts/epicSabnzbdVideo.sh"

if [[ "$2" == "movies" ]]; then
    win_path="X:\\\media\\\Movies"
    lnx_path="/media/tardis-x/media/Movies"
    if [[ "$3" == "tag" ]]; then
        options="x x x movies x x tag"
    else
        options="x x x movies x x"
    fi
elif [[ "$2" == "tv" ]]; then
    win_path="X:\\\media\\\TV"
    lnx_path="/media/tardis-x/media/TV"
    if [[ "$3" == "tag" ]]; then
        options="x x x tv x x tag"
    else
        options="x x x tv x x"
    fi
else
   echo "!!! Error, '\$2' not specified."
   exit 1
fi

dir=$(sed "s|"$win_path"|"$lnx_path"|g" <<< $1)
dir=$(sed 's|\\|\/|g' <<< $dir)
echo "'$script' '$dir' '$options'"
"$script" "$dir" $options
