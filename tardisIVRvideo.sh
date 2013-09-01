#!/bin/bash
echo "epicSabnzbdVideo.sh-v1"
# credits to the original author; https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
#
# You need to put this script where SAB is set for the script location
# SAB | Config | Folders | Post-Processing Scripts Folder
# You can modify this location, but make sure the script goes where you are telling
# SAB where the scripts are located.
# For me it works best in SAB | Config | Switches | set the Default User Script to AppleTV
# Some locations below are hardcoded in this script
# All of the settings in this script which may vary from machine to machine are preceeded with:
# "##### The line below contains a user defined location setting"
# Search for the 5 pound signs and update the lines below them all to suit your system.
# There are 3 applications you need to install for this script to properly function
#
# 1) HandbrakeCLI (encodes the video for AppleTV)
# Download from: http://handbrake.fr/downloads.php
# Free
#
# 2) Mencoder (used for joining 2 AVI's)
# Download from: http://www.mplayerhq.hu/design7/dload.html#binaries
# Mencoder is one of the files in the MPlayer download
# Free
#
# 3) iDentify (Tags Movies with info and cover art)
# iDentify is fully capable to tag TV Shows also, but I find that since I'm a
# Watch and Delete person for TV, I'm fine with basic Show, Season, and Episide tags
# which I can do without aid of a third party application. But for Movies, I want it all.
# Download from: http://www.macupdate.com/info.php/id/33814/identify-2
# Free for a version with limited use, pay the $10 for full version, it is worth it
#
# Output Parameters from SABnzbd+
# SABnzbd pushes these parameters to the post processing script
DIR=$1
NZB_FILE=$2
NAME=$3
NZB_ID=$4
CATEGORY=$5
GROUP=$6
STATUS=$7
echo Debug
echo DIR: $DIR
echo NZB_FILE: $NZB_FILE
echo NAME: $NAME
echo NZB_ID: $NZB_ID
echo CATEGORY: $CATEGORY
echo GROUP: $GROUP
echo STATUS: $STATUS
echo NAMElc: $NAMElc
echo CATEGORYlc: $CATEGORYlc
echo
# You can set 'fake' output parameters from SABnzbd+ here for testing on any file in any folder# DIR="/Users/randyharris/desktop/TVShow.No.Season.Or.Episode.WS.720P.HDTV.Lima"
# NZB_FILE="TVShow.No.Season.Or.Episode.WS.720P.HDTV.Lima.nzb"
# NAME="TVShow.No.Season.Or.Episode.WS.720P.HDTV.Lima"
# NAME="the.daily.show.s01e01.tim.gunn.hdtv.x264-evolve"
# NZB_ID=""
# CATEGORY="tv"
# GROUP="alt.binaries.racing"
# STATUS="0"
# Set NAME to all lower case for more reliable testing
NAMElc=$(echo $NAME|tr '[A-Z]' '[a-z]')
CATEGORYlc=$(echo $CATEGORY|tr '[A-Z]' '[a-z]')
#======================================================================================
#======================================================================================
#
# This section of the script is for Movies.
#
# Note that I don't even attempt to mess with Subtitles, largely because HandBrake won't
# burn subtitles from MKV source material - stinks I know. So make other arrangements
# for subtitled movies.
#
# In SABnzbd SORTING be certain to Enable Movie Sorting.
# You can use any sort string that you prefer, but please use this string for Multi-part label:
# " CD%1" (don't include the quotes)
#
# The script will check and join 2 AVI's so that you have a single video file,
# it will check and convert VIDEO_TS file structure to ISO so that HandBrakeCLI can convert it
# The file is then converted for AppleTV.
#
# Then the file is opened in iDentify. I have iDentify setup so that I preview the tag information
# that it found for the movie before I process it (hard code it to the movie.)
# My iDentify preferences that are important
# GENERAL, YES to Automatically Add to iTunes After Tagging
# Note you have to donate $10 to enable this feature, well worth it to me.
# FILE RENAMING, NO to Rename movies after Tagging (this can be fine to use if you set it up how you like.)
# Setting the variables for Destination Folder
##### The line below contains a user defined location setting
if [ -z "$CATEGORY" ]; then
	exit 1
fi

if [ "$CATEGORYlc" = "movies" ]; then
	dest_folder="/media/tardis-x/downloads/epic/postprocessing/couchpotato"
	echo " - Processing as a Movie."
	echo
	# Won't print error in for loop if there are no video files in the folder
	shopt -s nullglob
	# Join 2 AVIs
	# Some XviD releases are packaged into two files that will fit onto a CDROM. Since we are
	# watching movies on an AppleTV it's more convenient to have the movie in 1 file not 2.
	# This section will look for two AVI files, CD1 and CD2 and combine them into a single file
	# then create a sub-folder and move the two original AVIs into that folder for safe keeping
	cd "$DIR"
	# The SAB sort string should name multiple AVI's with capital CD1 and CD2
	for i in *CD2.avi ; do
		echo " - An AVI file with 'CD2' was found:"
		avimerge -o "$NAME.avi" -i *CD1.avi *CD2.avi > /dev/null 2>&1
		echo " - Combine completed."
		mkdir "Unjoined AVIs"
		mv *CD1.avi "Unjoined AVIs/."
		mv *CD2.avi "Unjoined AVIs/."
		echo " - Old AVI's moved into 'Unjoined AVIs'"
		echo
	done

	# Just in case CD1 and CD2 are actually cd1 and cd2
	for i in *cd2.avi; do
		echo
		echo " - An AVI file with 'cd2' was found:"
		avimerge -o "$NAME.avi" -i *cd1.avi *cd2.avi > /dev/null 2>&1
		echo " - Combine completed."
		mkdir "Unjoined AVIs"
		mv *cd1.avi "Unjoined AVIs/."
		mv *cd2.avi "Unjoined AVIs/."
		echo " - Old AVI's moved into 'Unjoined AVIs'"
		echo
	done

	# Convert the source video file to AppleTV M4V
	#
	# First this section checks to be sure that you don't already have an AppleTV file with the
	# same name in the Destination Folder. If not, it will convert all video files to the
	# Destination Folder. Ideally there will only be 1 file converted, but sometimes there are
	# other video files that could be present. To help reduce the amount of unwanted video files
	# it is recommended that you go into SABnzbd | Config | Switches | and set "Ignore Samples"
	# to Do not download.
	#
	# After the encoding is complete the movie will be opened into iDentify for tagging/cover art.
	# Lastly the folder containing the source video and possibly original CD1/CD2 AVI's will be moved
	# into the Trash bin so that they are out of your way but retreivable until you empty your Trash.
	# The encoding section into two sections because 1) Video files and 2) VIDEO_TS structure
	# This is the first of two sections - it is looking for movies in single files, MKV, ISO, etc.
	cd "$DIR"
	for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img; do
		# Setting the variables for Destination File
		dest_file="${i%.*}"".m4v"
		echo "Transcoding"
		echo
		echo " - Destination folder:"
		echo " $dest_folder"
		echo
		echo " - Destination file:"
		echo " $dest_file"# If there is already an M4V file stop
	
		if [ -e $dest_folder$dest_file ]; then
			echo " - Destination file already exists, skipping $i"
			continue
		fi
	
		# Convert the source video file to an AppleTV M4V file using HandBrake
		##### The line below contains a user defined location setting
		handbrake-cli -i "$i" -o "$dest_folder$dest_file" --longest --preset="AppleTV" > /dev/null 2>&1
		# Note the " > /dev/null 2>&1" at the end of the line directs output from HandBrakeCLI away from the script log
		echo " - Transcode completed"
		echo
	
		# Use iDentify to Tag and import into iTunes
		#echo "Opening in iDentify to Tag and inject into iTunes as a Movie"
		##### The line below contains a user defined location setting
		#open -a /Applications/iDentify.app "$dest_folder$dest_file"
	done
	
	# This is the second of two sections - it is looking for movies in VIDEO_TS DVD rips
	if [ -e $DIR/VIDEO_TS/VIDEO_TS.IFO ]; then
		# Can't use the file name since this is a VIDEO_TS rip, using folder name instead
		cd "$DIR"
		IFS="/"
		set -- $(pwd)
		i=$(($#-1))
		shift $i
		dest_file="$1.m4v"
		echo " - Destination folder:"
		echo " $dest_folder"
		echo
		echo " - Destination file:"
		echo " $1.m4v"
	
		# If there is already an M4V file stop
		if [ -e $dest_folder$dest_file ]; then
			echo " - Destination file already exists, skipping $i"
			continue
		fi

		##### The line below contains a user defined location setting
		handbrake-cli -i "$DIR" -o "$dest_folder$1.m4v" --longest --preset="AppleTV" > /dev/null 2>&1
		# Note the " > /dev/null 2>&1" at the end of the line directs output from HandBrakeCLI away from the script log
		echo " - Transcode completed."
		echo

		# Use iDentify to Tag and import into iTunes
		# echo "Opening in iDentify to Tag and inject into iTunes as a Movie"
		##### The line below contains a user defined location setting
		# open -a /Applications/iDentify.app "$dest_folder$1.m4v"
	fi

	# Move the source folder to the Trash Bin
	echo
	echo "Deleting original source files."
	cd ~/
	mv "$DIR" /media/tardis-x/downloads/epic/trash
	# mv "$DIR" ~/.Trash
	# Post Processing as a Movie complete
	# echo "Movie is AppleTV ready, check/apply Tags in iDentify."
	#======================================================================================
	#======================================================================================

elif [ "$CATEGORYlc" = "tv" ]; then
	# This section of the scripts is for TV Shows / Series that contain Season and Episode info
	# You need to have SABnzbd SORTING set to match what this script is looking for (or change
	# the regex line to suit your output.
	#
	# Enable TV Sorting in SAB and use this string:
	# "%sn - S%0sE%0e/%sn - S%0sE%0e.%ext" (don't include the quotes)
	# Which results in this example:
	# /Users/username/desktop/Show Name - S01E05/Show Name - S01E05.avi
	echo " - Processing as a TV Show / Series."
	# Won't print error in for loop if there are no video files in the folder
	shopt -s nullglob
	# Regex expression parse Tag information from the filename
	# This parses information from the Job Name for tagging and file naming
	regex="^(.+) - [Ss]([[:digit:]]+)[Ee]([[:digit:]]+).*$"
	# Navigate to folder with the video file
	cd "$DIR"
	# Convert the source video file to AppleTV M4V
	#
	# First this section checks to be sure that you don't already have an AppleTV file with the
	# same name in the Destination Folder. If not, it will convert all video files to the
	# Destination Folder. Ideally there will only be 1 file converted, but sometimes there are
	# other video files that could be present. To help reduce the amount of unwanted video files
	# it is recommended that you go into SABnzbd | Config | Switches | and set "Ignore Samples"
	# to Do not download.
	#
	# After the encoding is complete the Formula1 race will be injected into iTunes with basic tag
	# information, Show Name = Formula1, Episode name = Venue, Season is hard coded to the current year,
	# Episode is hard coded to 01.
	#
	# Lastly the folder containing the source video will be moved into the Trash bin so that they
	# are out of your way but retreivable until you empty your Trash.

	for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img; do
		NAME=${i%.*}
		if [[ "$CATEGORYlc" = "tv" && "$NAME" =~ "$regex" ]]; then
			show_name=${BASH_REMATCH[1]}
			season=${BASH_REMATCH[2]}
			episode=${BASH_REMATCH[3]}
			episode_name=${BASH_REMATCH[4]}
		fi
	
		# Setting the variables for Destination File and Folder
		dest_file=""$show_name" - S"$season"E"$episode" - "$episode_name".m4v"
		##### The line below contains a user defined location setting
		dest_folder="/media/tardis-x/downloads/epic/postprocessing/sickbeard"
		dest_false=" - SE.m4v"
	
		# Using info available if no SxxExx information
		# Some shows don't have Season and Episode information, this section will check
		# and if no Season and Episode information exists, then it will base tag info
		# Off of the Job Name and current year, and set Episode to 01.
		if [ "$dest_file" = "$dest_false" ]; then
			echo " - Proceeding without SxxExx info."
			echo
			# Dress up the Job Name to look how I want it in iTunes
			# Change periods to spaces
			tag2=$(echo $NAME|sed 's/\./ /g')
			# Strip everything after "PDTV" or "HDTV" or "720P" or "WS" or "iTouch" or "DVDrip" or "XviD"
			tag4=$(echo $tag3|sed 's/[pP][dD][tT][vV].*//g')
			tag5=$(echo $tag4|sed 's/[hH][dD][tT][vV].*//g')
			tag6=$(echo $tag5|sed 's/[7][2][0][pP].*//g')
			tag7=$(echo $tag6|sed 's/[wW][sS].*//g')
			tag8=$(echo $tag7|sed 's/[iI][tT][oO][uU][cC][hH].*//g')
			tag9=$(echo $tag8|sed 's/[dD][vV][dD][rR][iI][pP].*//g')
			tag10=$(echo $tag9|sed 's/[xX][vV][iI][dD].*//g')
			# Strip any trailing spaces
			tag11=$(echo $tag10|sed 's/[ \t]*$//')
			# Make sure the first letter of every word is Capitalized
			tag12=$( echo "${tag11}" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
			show_name=$tag12
			season=$(date '+%Y')
			episode="01"
			dest_file="$tag11.m4v"
		fi
	
		if [ "$show_name" == "" ]; then
			echo "Something went wrong during filename parse."
			exit 1
		fi
	
		# If there is already an M4V file stop
		if [ -e "$dest_folder$dest_file" ]; then
			echo " - An M4V with the same name already exisits,"
			echo " - skipping $i"
			continue
		fi
	
		# Convert the source video file to an AppleTV M4V file using HandBrake
		echo "Transcoding the TV Show."
		##### The line below contains a user defined location setting
		handbrake-cli -i "$i" -o "$dest_folder$dest_file" --longest --preset="AppleTV" > /dev/null 2>&1
		# Note the " > /dev/null 2>&1" at the end of the line directs output from HandBrakeCLI away from the script log
		echo " - Transcode completed."
		echo
	
		# If HandBrake did not exit gracefully, continue with next iteration
		if [ $? -ne 0 ]; then
			continue
		fi

		# Add converted video file into iTunes
		echo
		echo " - TV Show: $show_name"
		echo " - Season: $season"
		echo " - Episode: $episode"
		echo " - Episode Name: $episode_name"
		echo " - File: $dest_file"
		echo " - Folder: $dest_folder"
		# echo "Tagging and injecting into iTunes"
		# osascript <<APPLESCRIPT
		# tell application "iTunes"
		# set posix_path to "$dest_folder" & "$dest_file"
		# set mac_path to posix_path as POSIX file
		# set video to (add mac_path)
		# set video kind of video to TV Show
		# set show of video to "$show_name"
		# --
		# set season number of video to "$season"
		# --
		# set episode number of video to "$episode"
		# --
		# set episode ID of video to "$episode_name"
		# end tell
		# APPLESCRIPT

		atomicparsley "$dest_folder$dest_file" --overWrite --title "$show_name" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisodeNum "$episode" --TVSeasonNum "$season" --description "$episode_name"
		echo " - AtomicParsley completed."
		echo
	
		# Move the source folder to the Trash Bin
		echo "Deleting original source files."
		echo
		cd ~/
		mv "$DIR" /media/tardis-x/downloads/epic/trash
		# mv "$DIR" ~/.Trash
		# Post Processing for TV Show complete
		echo "The TV Show is ready to be added to iTunes."
	done
fi
exit 0
