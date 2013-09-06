#!/bin/bash
date
# big thanks to the original author(s), especially the BASH/OSX community
# author 1) https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
# author 2) ???
#
# some applications you need
#
# HandbrakeCLI (transcodes video)
# Mencoder (used for joining 2 AVI's)
# mkisofs (convert VIDEO_TS folders to .iso format)
# tvrenamer.pl (fetches episode names for SxxExx TV Shows)
#    Written by: Robert Meerman (robert.meerman@gmail.com, ICQ# 37099562)
#    Website: http://www.robmeerman.co.uk/coding/file_rename
# AtomicParsley (tags video files with info and cover art)

# sample option 'Ignore Samples' in Sabnzbd | Config | Switches, must be set to 'Do not download'

# user definable locations

# Movie transcoded file destination
movie_dest_folder="/media/tardis-x/downloads/epic/postprocessing/couchpotato/"

# Movie original downloaded file destination
# this script keeps the original files in case something goes wrong.  empty this dir regularly.
unwatched_dest_folder="/media/tardis-x/downloads/epic/trash/"

# Movie artwork location if you have it
# files must be formatted to match the Show Name and have a jpg extension eg: "The Show Name.jpg"
movieartwork="/media/tardis-x/downloads/epic/artwork/movies/"

# Movie HandBrake preset
movie_preset="AppleTV"

# TV Show transcoded file destination
tv_dest_folder="/media/tardis-x/downloads/epic/postprocessing/sickbeard/"

# TV Show original downloaded file destination
postproc_dest_folder="/media/tardis-x/downloads/epic/trash/"

# TV Show transcoded file destination when TV Show information is not found
dest_false=" - SE.m4v"

# TV Show artwork location if you have it
# files must be formatted to match the Show Name and have a jpg extension eg: "The Show Name.jpg"
tvartwork="/media/tardis-x/downloads/epic/artwork/tv/"
   
# TV Show HandBrake preset
tv_preset="AppleTV"

# SABnzbd output parameters
DIR=$1
NZB_FILE=$2
NAME=$3
NZB_ID=$4
CATEGORY=$5
GROUP=$6
STATUS=$7

# test SABnzbd parameters
# DIR="/Volumes/Irulan/Movies/0, New/Movie (2009)/"
# NZB_FILE="Movie (2009).nzb"
# NAME="Movie (2009)"
# NZB_ID=""
# CATEGORY="movies"
# GROUP="alt.binaries.teevee"
# STATUS="0"

########################################
# /begin CATEGORY = Movie
########################################

if [[ $CATEGORY = "movies" ]]; then
   echo "  - Processing as a Movie"
   echo
   
   # stops error printing in loop if there are no video files in the folder
   shopt -s nullglob

   # find locally available artwork
   cd "$DIR"
   if [ $? -ne 0 ]; then
   echo "$?"
   echo "!!! ERROR, cd '$DIR'"
   date
   exit 1
   fi

   find . -type f -maxdepth 1 -name '*.jpg' -exec mv '{}' "$movieartwork$NAME.jpg" \;

########################################
# mkisofs
########################################

# untested
   cd "$DIR"

   # find VIDEO_TS folder and files
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
   
   # move all video files into the main processing folder
   cd "$DIR"
   # finding files larger than 300MB for processing and delete files smaller than 30MB
   find "$DIR" -size +307200k -exec mv {} "$DIR" \;
   find "$DIR" -size -30720k -type f -exec rm {} \;
   echo "  - mv errors above are ok."
   echo

########################################
# Join AVIs using avimerge or mencoder
########################################

# untested
   # if there are 2 AVI's join them
   cd "$DIR"
   # finding .AVI files   
   for i in *{CD2,cd2}.avi; do
   echo "  - 2 AVI files found"
   # mencoder on linux requires a lot of dependencies.  let's try other methods more suitable for a headless server.
   # mencoder -forceidx -ovc copy -oac copy *{CD1,cd1}.avi *{CD2,cd2}.avi -o "$NAME.avi" > /dev/null 2>&1

# untested
   avimerge -o "$NAME.avi" -i *{CD1,cd1}.avi *{CD2,cd2}.avi > /dev/null 2>&1
   echo "  - AVImerge!!! complete"
   mkdir "Unjoined AVIs"
   mv *{CD1,cd1}.avi "Unjoined AVIs/."
   mv *{CD2,cd2}.avi "Unjoined AVIs/."
   echo "  - Moved original AVIs to folder 'Unjoined AVIs'"
   echo
   done
   
########################################
# Loop thru media files.  Transcode and Tag.
########################################

   # matches: movie name (2013).xyz
   regex="(.*) \(([0-9]{4})\).*"

   cd "$DIR"
   if [ $? -ne 0 ]; then
   echo "$?"
   echo "!!! ERROR, cd '$DIR'"
   date
   exit 1
   fi

   # find media files to convert
   for i in *.[mM][kK][vV] *.[aA][vV][iI] *.[mM][4][vV] *.[mM][pP][4] *.[wW][mM][vV] *.[iI][sS][oO] *.[iI][mM][gG] *.[tT][sS]; do
   NAME=${i%.*}
   EXT=${i##*.}
      
   if [[ $CATEGORY = "movies" && $NAME =~ $regex ]]; then
   echo "  - REGEX processing Movie,"
   echo "  - $regex"
   echo "  - $i"
   echo

   # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
   year=${BASH_REMATCH[2]}
   # customize movie title tag for atomicparsley
   # title =${BASH_REMATCH[1]} # = "Movie"
   title=$NAME # NAME = "Movie (2013)"

   else
   echo "!!! REGEX error,"
   echo "!!! skipping $i"
   echo
   continue
   fi

   # destination filename
   movie_dest_file="${i%.*}"".m4v"
         
########################################
# HandBrake
########################################

# experimental BlueRay .iso support
   regex_iso=".*[iI][sS][oO]"
   if [[ $i =~ $regex_iso ]]; then
   echo "  - REGEX processing ISO,"
   echo "  - $regex_iso"
   echo "  - $i"
   echo

   echo "  - mounting .iso,"
   # need sudo access with NOPASSWD
   sudo mount -o loop "$i" /media/iso

   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, mount .iso exit code"
   date
   exit 1
   fi

   if [[ -d /media/iso/BDMV ]]; then
   # find the largest .m2ts file
   M2TS=`find /media/iso/BDMV/STREAM -type f -print0 | xargs -0 du | sort -n | tail -1 | cut -f2`
   echo "  - Transcoding!!! BlueRay,"
   echo handbrake-cli -i "$M2TS" -o "atomicFile.m4v" --preset="$movie_preset"
   echo
   handbrake-cli -i "$M2TS" -o "atomicFile.m4v" --preset="$movie_preset" > /dev/null 2>&1
   sudo umount /media/iso
   continue
   fi

   fi

   # convert using handbrake
   echo "  - Transcoding!!!"
   echo handbrake-cli -i "$i" -o "atomicFile.m4v" --preset="$movie_preset"
   echo
#   handbrake-cli -i "$i" -o "$movie_dest_file" --preset="$movie_preset" > /dev/null 2>&1
   handbrake-cli -i "$i" -o "atomicFile.m4v" --preset="$movie_preset" > /dev/null 2>&1

   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, HandBrake exit code"
   date
   exit 1
   fi

   done

   # check output file created by handbrake
#   ls -l "$movie_dest_file" > /dev/null 2>&1
   ls -l "atomicFile.m4v" > /dev/null 2>&1
   if [[ $? -ne 0 ]]; then
   echo "$i"
   echo "!!! ERROR, HandBrake atomicFile.m4v missing"
   date
   exit 1
   continue
   fi

########################################
# AtomicParsley
########################################

   # if artwork is available locally then tag.
   if [[ -e $(find "$movieartwork" -maxdepth 1 -name "$NAME.jpg") ]]; then
   echo "  - AtomicParsley!!!  tagging w/local artwork."
   atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --artwork "$movieartwork$NAME.jpg" --overWrite > /dev/null 2>&1
   else
   # just tag
   echo "  - AtomicParsley!!!  tagging w/o artwork."
   atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --overWrite > /dev/null 2>&1
   fi
   
   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, AtomicParsley exit code"
   date
   exit 1
   fi

   # move the transcoded file to a folder.
   echo "  - Moved transcoded file to folder."
   echo "  - mv "$movie_dest_file" "$movie_dest_folder""
# improve this
   mv "atomicFile.m4v" "$movie_dest_file"
   mv "$movie_dest_file" "$movie_dest_folder"

   if [ $? -ne 0 ]; then
   echo "$?"
   echo "!!! ERROR, mv exit code"
   date
   exit 1
   fi
   echo
   
   # move the original downloaded file to a folder.
   # don't fail if none is found.  i.e. re-encoding (moved) existing .m4v
   echo "  - Moved original downloaded file to folder."
   echo "  - mv "$i" "$postproc_dest_folder$i""
   mv "$i" "$postproc_dest_folder$i"
   echo

# untested
   # delete extraneous files and VIDEO_TS folder 
   #    rm -R "$DIR"
   #    echo
   #    echo "  - Original files moved to Movie Library"

########################################
# Cleanup, Move, and print details to log.
########################################

   echo "  - Details:"
   echo "    DIR:          $1"
   echo "    NZB_FILE:     $2"
   echo "    NAME:         $3"
   echo "    NZB_ID:       $4"
   echo "    CATEGORY:     $5"
   echo "    GROUP:        $6"
   echo "    STATUS:       $7"
   echo "    Input File:   $i"
   echo "    Dest Folder:  $movie_dest_folder"
   echo "    Dest File:    $movie_dest_file"
   echo "    Title:        $title"
   echo "    Year:         $year"
   echo
   date
   echo "  - COMPLETED!    $movie_dest_file"
fi

########################################
# /end CATEGORY = Movie
########################################

########################################
# /begin CATEGORY = TV
########################################

   # regex matches: show name - s01e02 - episode name.xyz
   regex="(.*) - S([0-9]{2})E([0-9]{2}) - (.*)$"

   # regex matches: the daily show - 2013-08-01 - episode name.xyz
   regex_dated="(.*)[- .]{3}([0-9]{4})[- .]([0-9]{2})[- .]([0-9]{2})[- .]{3}(.*).*"

   # custom processing for shows
   # regex matches: the soup - 2013-08-01 - episode name.xyz
   regex_soup="([tT][hH][eE]\s[sS][oO][uU][pP])[([0-9]{4})[- .]([0-9]{2})[- .]([0-9]{2})[(.*).*"

   if [[ $CATEGORY = "tv" ]]; then
   # stops error printing in loop if there are no video files in the folder
   shopt -s nullglob

   cd "$DIR"
   if [ $? -ne 0 ]; then
   echo "$?"
   echo "!!! ERROR, cd '$DIR'"
   date
   exit 1
   fi

   # Finding files and deleting any smaller than 30MB
   # this helps remove sample files that Sabnzbd accidentally downloads
   # echo "  - Deleting extraneous files."
   # find "$DIR" -size -30720k -type f -exec rm {} \;
   # echo

########################################
# Detect season vs dated naming.  i.e.  S01E02 vs 2013-08-01
########################################

   # get the filename
   for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img *.ts; do
   NAME=${i%.*}
   done

########################################
# Run tvrenamer.pl if SxxExx is detected.
########################################

   if [[ $CATEGORY = "tv" && $NAME =~ $regex  ]]; then
   # tvrenamer.pl get TV episode name 
   echo "  - Renaming the file with tvrenamer.pl"
   /usr/local/bin/tvrenamer.pl --unattended --gap=" - " --separator=" - " --pad=2 --scheme=SXXEYY --include_series > /dev/null 2>&1
   echo

   fi
   
########################################
# Loop thru media files.  Transcode and Tag.
########################################

   for i in *.mkv *.avi *.m4v *.mp4 *.wmv *.iso *.img *.ts; do
   NAME=${i%.*}

   # the soup requires custom processing
   if [[ $CATEGORY = "tv" && $NAME =~ $regex_soup ]]; then

   echo "  - REGEX processing The Soup,"
   echo "  - $regex_soup"
   echo "  - $i"
   echo

   # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
   show_name=${BASH_REMATCH[1]}
   year=${BASH_REMATCH[2]}
   month=${BASH_REMATCH[3]}
   day=${BASH_REMATCH[4]}
   # the soup doesn't have episode names episode_name=${BASH_REMATCH[5]}
   season=$year
   episode=$month$day

   # convert double space to single
   show_name=$(echo $show_name|sed 's/\s\s/\s/g')
   episode_name=$(echo $episode_name|sed 's/\s\s/\s/g')

## research fixup episode_name
#  episode_name=$(echo $episode_name|sed 's/[- .][pP][dD][tT][vV].*//g')
#  episode_name=$(echo $episode_name|sed 's/[- .][wW][eE][bB].*//g')

   # strip everything after " - HDTV"
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[hH][dD][tT][vV].*//g')
   # strip WEBRIP
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[wW][eE][bB][rR][iI][pP].*//g')
   # strip 1080P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}1080[pP].*//g')
   # strip 720P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}720[pP].*//g')
   # strip PROPER
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}PROPER.*//g')

   # destination filename
   tv_dest_file=$show_name" - "$year-$month-$day".m4v"

   elif [[ $CATEGORY = "tv" && $NAME =~ $regex_dated ]]; then

   echo "  - REGEX processing Dated TV Show,"
   echo "  - $regex_dated"
   echo "  - $i"
   echo

   # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
   show_name=${BASH_REMATCH[1]}
   year=${BASH_REMATCH[2]}
   month=${BASH_REMATCH[3]}
   day=${BASH_REMATCH[4]}
   episode_name=${BASH_REMATCH[5]}
   season=$year
   episode=$month$day

   # convert double space to single
   show_name=$(echo $show_name|sed 's/\s\s/\s/g')
   episode_name=$(echo $episode_name|sed 's/\s\s/\s/g')

## research fixup episode_name
#  episode_name=$(echo $episode_name|sed 's/[- .][pP][dD][tT][vV].*//g')
#  episode_name=$(echo $episode_name|sed 's/[- .][wW][eE][bB].*//g')

   # strip everything after " - HDTV"
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[hH][dD][tT][vV].*//g')
   # strip WEBRIP
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[wW][eE][bB][rR][iI][pP].*//g')
   # strip 1080P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}1080[pP].*//g')
   # strip 720P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}720[pP].*//g')
   # strip PROPER
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}PROPER.*//g')

   # destination filename
   tv_dest_file=$show_name" - "$year-$month-$day" - "$episode_name".m4v"

   elif [[ $CATEGORY = "tv" && $NAME =~ $regex ]]; then
   echo "  - REGEX Processing TV Show,"
   echo "  - $regex"
   echo "  - $i"
   echo

   # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
   show_name=${BASH_REMATCH[1]}
   season=${BASH_REMATCH[2]}
   episode=${BASH_REMATCH[3]}
   episode_name=${BASH_REMATCH[4]}

   # convert double space to single
   show_name=$(echo $show_name|sed 's/\s\s/\s/g')
   episode_name=$(echo $episode_name|sed 's/\s\s/\s/g')

## research fixup episode_name
#  episode_name=$(echo $episode_name|sed 's/[- .][pP][dD][tT][vV].*//g')
#  episode_name=$(echo $episode_name|sed 's/[- .][wW][eE][bB].*//g')

   # strip everything after " - HDTV"
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[hH][dD][tT][vV].*//g')
   # strip WEBRIP
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}[wW][eE][bB][rR][iI][pP].*//g')
   # strip 1080P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}1080[pP].*//g')
   # strip 720P
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}720[pP].*//g')
   # strip PROPER
   episode_name=$(echo $episode_name|sed 's/[- ]{1,3}PROPER.*//g')

   # destination filename
   tv_dest_file=$show_name" - S"$season"E"$episode" - "$episode_name".m4v"

   else
   echo "!!! ERROR, regex"
   echo "!!! skipping $i"
   continue
   fi

# improve this

   # If there is already an M4V file stop
   if [[ -e "$tv_dest_folder$tv_dest_file" ]]; then
   echo "!!! An M4V with the same name already exists,"
   echo "!!! skipping $i"
   continue
   fi

########################################
# HandBrake
########################################

   # when running via shell check for tag switch
   if [[ $8 != "tag" ]]; then 
   # convert using handbrake
   echo "  - Transcoding!!!"
   echo handbrake-cli -i "$i" -o "atomicFile.m4v" --preset="$tv_preset"
   echo
   handbrake-cli -i "$i" -o "atomicFile.m4v" --preset="$tv_preset" > /dev/null 2>&1
   # " > /dev/null 2>&1" at the end of the line directs output from HandBrake away from the script log
   
   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, HandBrake exit code"
   date
   exit 1
   fi

   elif [[ $8 == "tag" ]]; then
   mv "$i" "atomicFile.m4v"
   fi

   # check output file created by handbrake
   ls -l "atomicFile.m4v" > /dev/null 2>&1

   if [[ $? != 0 ]]; then
   echo "$i"
   echo "!!! ERROR, atomicFile.m4v missing"
   date
   exit 1
   continue
   fi

########################################
# AtomicParsley
########################################

   # get artwork from epguides.com
   epguidesartwork=$(echo $show_name|sed 's/ *//g')
   wget -N http://epguides.com/$epguidesartwork/cast.jpg > /dev/null 2>&1
   echo "  - Retrieved Artwork from http://epguides.com"

   # if artwork is available locally then tag.
   if [[ -e $(find "$tvartwork" -maxdepth 1 -name "$show_name.jpg") ]]; then
   echo "  - AtomicParsley!!!  tagging w/local artwork."
   atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "$tvartwork$show_name.jpg" --overWrite > /dev/null 2>&1

   # else get artwork if available from epguides.com and tag.
   elif [[ -e $(find . -name "cast.jpg") ]]; then
   echo "  - AtomicParsley!!!  tagging w/epguides.com artwork."
   atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "cast.jpg" --overWrite > /dev/null 2>&1

   # otherwise tag without artwork.
   else
   echo "  - AtomicParsley!!!  tagging w/o artwork."
   atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --overWrite > /dev/null 2>&1
   echo "  - Tag and rename completed."
   fi

   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, AtomicParsley exit code"
   date
   exit 1
   fi

########################################
# Cleanup, Move, and print details to log.
########################################

   # Finding files and deleting any smaller than 30MB
   echo "  - Deleting extraneous files."
   find "$DIR" -size -30720k -type f -exec rm {} \;
   echo

   # move the transcoded file to a folder.
   echo "  - Moved transcoded file to folder."
   echo "mv "atomicFile.m4v" "$tv_dest_folder$tv_dest_file""
   mv "atomicFile.m4v" "$tv_dest_folder$tv_dest_file"

   if [ $? != 0 ]; then
   echo "$?"
   echo "!!! ERROR, mv exit code"
   date
   exit 1
   fi
   echo
   
   # move the original downloaded file to a folder.
   # don't fail if none is found.  i.e. re-encoding (moved) existing .m4v
   echo "  - Moved original downloaded file to folder."
   echo "  - mv "$i" "$postproc_dest_folder$i""
   mv "$i" "$postproc_dest_folder$i"
   echo

   # Post Processing for TV Show complete
   echo "  - Details:"
   echo "    DIR:          $1"
   echo "    NZB_FILE:     $2"
   echo "    NAME:         $3"
   echo "    NZB_ID:       $4"
   echo "    CATEGORY:     $5"
   echo "    GROUP:        $6"
   echo "    STATUS:       $7"
   echo "    Input File:   $i"
   echo "    Dest Folder:  $tv_dest_folder"
   echo "    Dest File:    $tv_dest_file"
   echo "    Show Name:    $show_name"
   echo "    Season:       $season"
   echo "    Episode:      $episode"
   echo "    Episode Name: $episode_name"
   echo "    Year:         $year"
   echo "    Month:        $month"
   echo "    Day:          $day"
   echo
   date
   echo "  - COMPLETED!    $tv_dest_file"
   echo
   done
fi

########################################
# /end CATEGORY = TV
########################################
