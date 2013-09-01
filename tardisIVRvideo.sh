#!/bin/bash

# The script will post process TV and Movie files, it will join 
# multiple .avi files and create ISO image from VIDEO_TS folders.
# If it's a TV Show the files are renamed using tvrenamer.pl to my chosen naming convention.
# It then transcodes the files using Handbrake's preset for iPads.
# The preset can be altered to use any of the Handbrake current presets.
# AtomicParsley then tags the file for iTunes if it's a TV Show.
# The transcoded file is then moved to a folder of your choice.
# I have a 'watched folder action' on that folder and my Mac Desktop sees the new file and adds it to itunes.

# Some locations below are hardcoded in this script
# All of the settings in this script which may vary from machine to machine are preceeded with:
# "##### The line below contains a user defined location setting" 
# Search for the $ 'Dollar' signs and update the lines below them all to suit your system.


# There are 5 applications you need to install for this script to properly function
#
# 1) HandbrakeCLI (encodes the video for iPad)
#    Download from: http://handbrake.fr/downloads.php
#
#
# 2) Mencoder (used for joining 2 AVI's)
#    Download from: http://www.mplayerhq.hu/design7/dload.html#binaries
#    Mencoder is one of the files in the MPlayer download
#
#
# 3) mkisofs (Tags Movies and TV Shows with info and cover art)
#    Makes and ISO from your VIDEO_TS folders
#
#
# 4) tvrenamer.pl (Tags Movies with info and cover art)
#     Written by: Robert Meerman (robert.meerman@gmail.com, ICQ# 37099562)
#    Website: http://www.robmeerman.co.uk/coding/file_rename
#
#
# 5) Atomic Parsley (Tags Movies with info and cover art)
#    Add TV Show tagging information for iTunes using AtomicParsley: http://atomicparsley.sourceforge.net/
#    If you have the artwork for your TV Shows then this will also apply the image to the meta information for iTunes
#    there's a user definable parameter for the folder where you store these.
#


# Sample option 'Ignore Samples' in Sabnzbd | Config | Switches, must be set to 'Do not download'

##### User definable locations

##### Transcoded file destination
##### The line below contains a user defined location setting, change to where you want your transcoded files to go.
movie_dest_folder="/media/tardis-x/downloads/epic/postprocessing/couchpotato"

##### Original file destination
##### The line below contains a user defined location setting, change to where you want your processed files to go.
unwatched_dest_folder="/media/tardis-x/downloads/epic/trash"

##### TV Show artwork location if you have it
##### Files must be formatted to match the Show Name and have a jpg extension eg: "The West Wing.jpg"
##### The line below contains a user defined location setting, this is the folder where you store your TV Show artwork
movieartwork="/media/tardis-x/downloads/epic/artwork/movies/"

##### Movie Preset transcoding options
##### The line below contains a user defined Handbrake preset.
##### Change the line 'movie_preset="iPad"' substitute "iPad" with another preset. 
##### Preset options are:
##### 'Apple= Universal, iPod, iPhone, iPad, AppleTV, QuickTime, Legacy, AppleTV Legacy, iPhone Legacy, iPod Legacy'
##### 'Basic= Normal, Classic'
##### 'High Profile= Animation, Constant Quality Rate, Film, Television'
##### 'Gaming Consoles= PSP, PS3, Xbox 360'
movie_preset="AppleTV"

##### TV Show transcoded file destination
##### The line below contains a user defined location setting, change to where you want your transcoded files to go.
tv_dest_folder="/media/tardis-x/downloads/epic/postprocessing/sickbeard"

##### TV Show transcoded file destination where no TV Show information was found
##### The line below contains a user defined location setting, change to where you want your transcoded files to go.
dest_false=" -  SE.m4v"

##### TV Show artwork location if you have it
##### Files must be formatted to match the Show Name and have a jpg extension eg: "The West Wing.jpg"
##### The line below contains a user defined location setting, this is the folder where you store your TV Show artwork
tvartwork="/media/tardis-x/downloads/epic/artwork/tv/"
   
##### TV Show Preset transcoding options
##### Change the line 'tv_preset="iPad"' substitute "iPad" with another preset. 
##### Preset options are:
##### 'Apple= Universal, iPod, iPhone, iPad, AppleTV, QuickTime, Legacy, AppleTV Legacy, iPhone Legacy, iPod Legacy'
##### 'Basic= Normal, Classic'
##### 'High Profile= Animation, Constant Quality Rate, Film, Television'
##### 'Gaming Consoles= PSP, PS3, Xbox 360'
##### The line below contains a user defined Handbrake preset.
tv_preset="AppleTV"

# SABnzbd output parameters
DIR=$1
NZB_FILE=$2
NAME=$3
NZB_ID=$4
CATEGORY=$5
GROUP=$6
STATUS=$7

# Fake SABnzbd parameters
# DIR="/Volumes/Irulan/Movies/0, New/Movie (2009)/"
# NZB_FILE="Movie (2009).nzb"
# NAME="Movie (2009)"
# NZB_ID=""
# CATEGORY="movies"
# GROUP="alt.binaries.teevee"
# STATUS="0"

####################
# Movie Processing #
####################


if [ $CATEGORY == "movies" ]; then
   echo "  - Processing as a Movie"
   echo
   
   # Stops error printing in loop if there are no video files in the folder
   shopt -s nullglob

#===============================================================================
# Find Movie Artwork if in folder
   cd "$DIR"
   find . -type f -maxdepth 1 -name '*.jpg' -exec mv '{}' "$movieartwork$NAME.jpg" \;

#===============================================================================
# If VIDEO_TS will be converted to ISO image
   cd "$DIR"
   # Finding VIDEO_TS folder and files
   if [[ -e $(find . \( ! -regex '.*/\..*' \) -type f -name "VIDEO_TS.IFO") ]]; then
      IFO=$(find . \( ! -regex '.*/\..*' \) -type f -name "VIDEO_TS.IFO")
      echo "folder/file: $IFO"
      VIDEOTS=$(echo $IFO|sed 's/[vV][iI][dD][eE][oO][_][tT][sS][.][iI][fF][oO].*//g')
      VIDEOTSROOT=$(echo $VIDEOTS|sed 's/[vV][iI][dD][eE][oO][_][tT][sS].*//g')
      echo
      echo "VIDEO_TS Found, converting to an ISO"
      mkisofs -input-charset iso8859-1 -dvd-video -o "$DIR/$NAME.iso" "$VIDEOTSROOT"  > /dev/null 2>&1
      echo
      echo "  - Conversion to ISO complete"
      echo
      rm -R "$VIDEOTSROOT"
      echo "  - Deleted VIDEO_TS folder"
      echo
      
   fi
   
#===============================================================================
# Move all video files into the main processing folder
   cd "$DIR"
   
   # Finding files larger than 300MB for processing and delete files smaller than 30MB
   find "$DIR" -size +307200k -exec mv {} "$DIR" \;
   find "$DIR" -size -30720k -type f -exec rm {} \;

#===============================================================================
# if there are 2 AVI's join them
   cd "$DIR"
   # Finding multiple .AVI files   
   for i in *{CD2,cd2}.avi; do
      echo "  - 2 AVI files where found Joining them together:"
      mencoder -forceidx -ovc copy -oac copy *{CD1,cd1}.avi *{CD2,cd2}.avi -o "$NAME.avi" > /dev/null 2>&1
      echo "  - Combine completed"
      mkdir "Unjoined AVIs"
      mv *{CD1,cd1}.avi "Unjoined AVIs/."
      mv *{CD2,cd2}.avi "Unjoined AVIs/."
      echo "  - Old AVIs moved into 'Unjoined AVIs' folder"
      echo
   done


   
#===============================================================================
# Transcode with Handbrake to preset
   cd "$DIR"
   # Finding media files to convert
   for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img; do
      
      # Setting the variables for Destination File
      movie_dest_file="${i%.*}"".m4v"
         
      # Convert the source video file to a preset M4V file using HandBrake
      handbrake-cli -i "$i" -o "$movie_dest_file" --preset="$movie_preset"    > /dev/null 2>&1
      echo
      echo "  - Conversion to m4v complete"
   done

#===============================================================================   
# Add Movie Show tagging information for iTunes using AtomicParsley: http://atomicparsley.sourceforge.net/
# If Artwork is available locally for the show then this tags the image
   if [[ -e $(find "$movieartwork" -maxdepth 1 -name "$NAME.jpg") ]]; then
   echo "  - Adding Artwork for movie from Artwork folder"
   atomicparsley "$movie_dest_file" --genre "Movie" --stik "Movie" --artwork "$movieartwork$NAME.jpg" --overWrite > /dev/null 2>&1
   fi
   
   # Move converted file to Destination folder
   mv "$movie_dest_file" "$movie_dest_folder"
   echo
   echo "  - Converted m4v moved to folder for import iTunes"
   
   # Move Unconverted files to Movie Library 
   mv "$i" "$unwatched_dest_folder"
   echo
   echo "  - Original files moved to Movie Library"

   # Delete extraneous files and VIDEO_TS folder 
#    rm -R "$DIR"
#    echo
#    echo "  - Original files moved to Movie Library"

   # Post Processing as a Movie complete
   echo
   echo "  - The Movie is in your iTunes library ready to sync to your iPad"   
fi

#################
# TV Processing #
#################

if [ $CATEGORY == "tv" ]; then
   echo 
   echo "  - Processing as a TV Show"
   echo 
   
   # Stops error printing in loop if there are no video files in the folder
   shopt -s nullglob
   
#===============================================================================
# TV Shows Transcoding and Tagging
   cd "$DIR"
   
   # Use tvrenamer.pl to scrape the TV Episode name 
   /usr/local/bin/tvrenamer.pl --unattended --gap=" - " --separator=" - " --pad=2 --include_series > /dev/null 2>&1
   echo "  - Renaming the file with tvrenamer.pl"
   echo
   
   # Regex expression parse Tag information from the filename
   # This parses information from the Job Name for tagging and file naming
   regex="^(.*) - ([[:digit:]]+)x([[:digit:]]+).* - (.*)$"
   
   for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img; do
   NAME=${i%.*}

   if [[ $CATEGORY -eq "tv" && $NAME =~ $regex ]]; then
   show_name=${BASH_REMATCH[1]}
   season=${BASH_REMATCH[2]}
   episode=${BASH_REMATCH[3]}
   episode_name=${BASH_REMATCH[4]}
   fi
   
   # Setting the variables for Destination File and Folder
   # tv_dest_file=$show_name" - "$season"x"$episode" - "$episode_name".m4v"
   tv_dest_file=$show_name" - S"$season"E"$episode" - "$episode_name".m4v"

   #TV Show original file destination
   #The line below contains a user defined location setting, change to where you want your processed files to go.
   postproc_dest_folder="/media/tardis-x/downloads/epic/trash"

   # If there is already an M4V file stop
   if [[ -e "$tv_dest_folder$tv_dest_file" ]]; then
      echo "  - An M4V with the same name already exists,"
      echo "  - skipping $i"
      continue
   fi

   
   # Convert the source video file to a preset M4V file using HandBrake
   handbrake-cli -i "$i" -o "$tv_dest_file" --preset="$tv_preset" > /dev/null 2>&1   
   # Note the " > /dev/null 2>&1" at the end of the line directs output from HandBrakeCLI away from the script log
   echo "  - Transcoding the TV Show"
   
   # If HandBrake did not exit gracefully, continue with next iteration
   if [[ $? -ne 0 ]]; then
   continue
   fi
   
   
#===============================================================================
# TV Show Artwork

   # Get artwork from epguides.com
   epguidesartwork=$(echo $show_name|sed 's/ *//g')
   wget http://epguides.com/$epguidesartwork/cast.jpg > /dev/null 2>&1
   echo "  - Retrieved Artwork from http://epguides.com"

   # Display tags
   echo File Name:\t$tv_dest_file
   echo Show Name:\t$show_name
   echo Season:\t$season
   echo Episode:\t$episode
   echo Episode Name:\t$episode_name
   
   # Add TV Show tagging information for iTunes using AtomicParsley: http://atomicparsley.sourceforge.net/
   # If Artwork is available locally for the show then this tags the show info and image
   if [[ -e $(find "$tvartwork" -maxdepth 1 -name "$show_name.jpg") ]]; then
   echo "  - Adding TV Show information and Artwork from Artwork folder"
   atomicparsley "$tv_dest_file" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --artwork "$tvartwork$show_name.jpg" --overWrite > /dev/null 2>&1

   # Add TV Show tagging information for iTunes using AtomicParsley: http://atomicparsley.sourceforge.net/
   # If Artwork is available from epguides.com then this tags the show info and image
   elif [[ -e $(find . -name "cast.jpg") ]]; then
   echo "  - Adding TV Show information and Artwork from epguides.com"
   atomicparsley "$tv_dest_file" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --artwork "cast.jpg" --overWrite > /dev/null 2>&1

   # Otherwise the tagging information minus the Artwork is added
   else
   echo "  - Adding TV Show information to the file for iTunes"
   atomicparsley "$tv_dest_file" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --overWrite > /dev/null 2>&1
   echo "  - Tag and rename completed"
   fi

   # Finding files and deleting any smaller than 30MB
   find "$DIR" -size -30720k -type f -exec rm {} \;
   echo
   echo "  - Deleted extraneous files"

   # Move the transcoded file to a folder which has folder actions set to input the file into iTunes
   mv "$tv_dest_file" "$tv_dest_folder"
   echo
   echo "  - Moved transcoded file to folder for Applescript to add into iTunes library"
   
   # Move the file to library for viewing in original format
   #mkdir -p "$postproc_dest_folder"; mv "$i" "$postproc_dest_folder$i"
   #echo
   #echo "  - Moved downloaded file to TV library for archive or viewing in original format"
   
   # Post Processing for TV Show complete
   echo
   echo "  - The TV Show is in your iTunes library ready to sync to your iPad."
   done
fi
