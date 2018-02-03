#!/bin/bash

# Home; https://github.com/scrathe/tardisIVR

# BIG thanks to the original author(s), especially the BASH/OSX community who helped me achieve my goals.
# author 1) https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
# author 2+) ??? (the scores of unnamed authors)

# Prerequisites
# .iso support requires sudo nopasswd for the mount/unmount commands.
# apt-get update && apt-get install autoconf automake bc build-essential software-properties-common zlib1g-dev -y

# HandBrake releases for Ubuntu https://github.com/HandBrake/HandBrake
# apt-get install software-properties-common -y
# add-apt-repository ppa:stebbins/handbrake-releases -y
# apt-get update
# apt-get install handbrake-cli -y

# AtomicParsley
# curl https://bitbucket.org/wez/atomicparsley/get/9183fff907bf.zip --output atomicparsley.zip"
# unzip atomicparsley.zip -d /opt
# mv /opt/wez-* /opt/atomicparsley
# cd /opt/atomicparsley && ./autogen.sh && ./configure && make && make install

# user definable locations
# ensure ALL directories end with '/'

# Media types that should be re-encoded
media_types="avi|divx|img|iso|m4v|mkv|mp4|ts|wmv"

# Movie transcoded file destination
movie_dest_folder="/movies/postprocessing/movies/"

# Movie original downloaded file destination
# this script keeps the original files in case something goes wrong. empty this dir regularly.
unwatched_dest_folder="/movies/postprocessing/trash/movies/"

# Movie artwork location if you have it
# files must be formatted to match the Show Name and have a jpg extension eg: "The Movie Name.jpg"
movie_artwork="/movies/postprocessing/movies/artwork/"

# TV Show transcoded file destination
tv_dest_folder="/tv/postprocessing/tv/"

# TV Show original downloaded file destination
postproc_dest_folder="/tv/postprocessing/trash/tv/"

# TV Show transcoded file destination when TV Show information is not found
dest_false=" - SE.m4v"

# TV Show artwork location if you have it
# files must be formatted to match the Show Name and have a jpg extension eg: "The TV Show Name.jpg"
tv_artwork="/tv/postprocessing/tv/artwork/"

# HandBrake options https://github.com/HandBrake/HandBrake
handbrake_options="-e x264 -q 20 --optimize --srt-lang eng --native-language eng --native-dub -f mp4 --decomb --loose-anamorphic --modulus 2 -m --x264-preset medium --h264-profile high --h264-level 4.1"

# HandBrake alias 
handbrake_cli=$(which HandBrakeCLI)

# set metadata into MPEG-4 files https://github.com/wez/atomicparsley
# 0 = disable
# 1 = enable
enable_atomicparsley="1"
# AtomicParsley alias
atomicparsley=$(which AtomicParsley)

# automatic TV episode file renamer, uses data from thetvdb.com via tvdb_api https://github.com/dbr/tvnamer
# 0 = disable
# 1 = enable
enable_tvrenamer="0"

# initialize array to log errors
declare -a logArray=()

# SABnzbd output parameters
DIR="$1"
NZB_FILE="$2"
NAME="$3"
NZB_ID="$4"
CATEGORY="$5"
GROUP="$6"
STATUS="$7"

# test SABnzbd parameters
# DIR="/Volumes/Irulan/Movies/0, New/Movie (2009)/"
# NZB_FILE="Movie (2009).nzb"
# NAME="Movie (2009)"
# NZB_ID=""
# CATEGORY="movies"
# GROUP="alt.binaries.teevee"
# STATUS="0"

# this fixes some problems; https://stackoverflow.com/questions/12729784/mv-cannot-stat-error-no-such-file-or-directory-error
# or maybe this;  shopt -s nullglob
shopt -s extglob

encodeMovie(){
  # $1 = atomicFile_XXX.m4v
  # detect .iso and mount, detect BlueRay, convert, umount
  regex_iso="\.*[iI][sS][oO]$"

  if [[ "$file" =~ $regex_iso ]]; then
    echo "  - REGEX detected ISO,"
    iso_detected=1
    echo "  - $regex_iso"
    echo "  - $file"
    echo

    echo "  - mounting .iso,"
    # need sudo access with NOPASSWD
    sudo mount -o loop "$file" /media/iso

    if [[ $? -ne 0 ]]; then
      echo "$?"
      echo "!!! ERROR, mount .iso exit code"
      date
      exit 1
    fi

    # BlueRay
    if [[ -d /media/iso/BDMV ]]; then
      # find the largest .m2ts file
      M2TS=`find /media/iso/BDMV/STREAM -type f -print0 | xargs -0 du | sort -n | tail -1 | cut -f2`
      # custom encode options based on audio channels; https://gist.github.com/donmelton/5734177
      channels="$(mediainfo --Inform='Audio;%Channels%' "$file" | sed 's/[^0-9].*$//')"
      if [[ $channels > 2 ]]; then
        handbrake_options="$handbrake_options --aencoder ca_aac,copy:ac3,copy:dts,copy:dtshd"
      elif [ "$(mediainfo --Inform='General;%Audio_Format_List%' "$file" | sed 's| /.*||')" == 'AAC' ]; then
        handbrake_options="$handbrake_options --aencoder copy:aac"
      fi
      echo "  - Audio Channels:  $channels"
      echo "  * Transcoding!!! BlueRay"
      echo "$handbrake_cli -i \"$M2TS\" -o $1 $handbrake_options"
      echo
      START=$(date +%s)
      $handbrake_cli -i "$M2TS" -o "$1" $handbrake_options > /dev/null 2>&1

      if [[ $? -ne 0 ]]; then
        echo "$?"
        echo "!!! ERROR, HandBrake exit code"
        date
        exit 1
      fi

      END=$(date +%s%N)
      echo "  - Encoding Speed: `echo "scale=2; ($END - $START) / 1000000000 / 60" | bc` minutes"
    fi

  # if not BlueRay just transcode
  else
    # custom encode options based on audio channels; https://gist.github.com/donmelton/5734177
    channels="$(mediainfo --Inform='Audio;%Channels%' "$file" | sed 's/[^0-9].*$//')"
    if [[ $channels > 2 ]]; then
      handbrake_options="$handbrake_options --aencoder ca_aac,copy:ac3,copy:dts,copy:dtshd"
    elif [ "$(mediainfo --Inform='General;%Audio_Format_List%' "$file" | sed 's| /.*||')" == 'AAC' ]; then
      handbrake_options="$handbrake_options --aencoder copy:aac"
    fi
    echo "  - Audio Channels:  $channels"
    echo "  * Transcoding!!!"
    echo "$handbrake_cli -i \"$file\" -o $1 $handbrake_options"
    echo
    START=$(date +%s%N)
    $handbrake_cli -i "$file" -o "$1" $handbrake_options> /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "$?"
      echo "!!! ERROR, HandBrake exit code"
      date
      exit 1
    fi

    END=$(date +%s%N)
    echo "  - Encoding Speed: `echo "scale=2; ($END - $START) / 1000000000 / 60" | bc` minutes"
  fi

  if [[ $iso_detected -eq 1 ]]; then
    echo "  - un-mounting .iso"
    sudo umount /media/iso
    echo
  fi

  # check output file created by handbrake
  ls -l "$1" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "!!! ERROR, HandBrake $1 missing"
    date
    exit 1
  fi
}

encodeTv(){
  # $1 = atomicFile_XXX.m4v
  # convert using handbrake
  # custom encode options based on audio channels; https://gist.github.com/donmelton/5734177
  channels="$(mediainfo --Inform='Audio;%Channels%' "$file" | sed 's/[^0-9].*$//')"
  if [[ $channels > 2 ]]; then
    handbrake_options="$handbrake_options --aencoder ca_aac,copy:ac3,copy:dts,copy:dtshd"
  elif [ "$(mediainfo --Inform='General;%Audio_Format_List%' "$file" | sed 's| /.*||')" == 'AAC' ]; then
    handbrake_options="$handbrake_options --aencoder copy:aac"
  fi
  echo "  - Audio Channels:  $channels"
  echo "  * Transcoding!!!"
  echo "$handbrake_cli -i \"$file\" -o $1 $handbrake_options"
  echo
  START=$(date +%s%N)
  # echo "" | $handbrake_cli; https://stackoverflow.com/questions/5549405/shell-script-while-read-loop-executes-only-once
  echo "" | $handbrake_cli -i "$file" -o "$1" $handbrake_options > /dev/null 2>&1
  # " > /dev/null 2>&1" at the end of the line directs output from HandBrake away from the script log

  if [[ $? != 0 ]]; then
    echo "!!! ERROR, HandBrake exit code"
    date
    exit 1
  fi

  END=$(date +%s%N)
  echo "  - Encoding Speed: `echo "scale=2; ($END - $START) / 1000000000 / 60" | bc` minutes"
}

printMovieDetails(){
  ISIZE=$(ls -lh "$1" | awk '{print $5}')
  OSIZE=$(ls -lh "$2" | awk '{print $5}')

  echo "  - Details:"
  echo "    DIR:             $DIR"
  echo "    NZB_FILE:        $NZB_FILE"
  echo "    NAME:            $NAME"
  echo "    NZB_ID:          $NZB_ID"
  echo "    CATEGORY:        $CATEGORY"
  echo "    GROUP:           $GROUP"
  echo "    STATUS:          $STATUS"
  echo "    Dest Folder:     $movie_dest_folder"
  echo "    Dest File:       $dest_file"
  echo "    Title:           $title"
  echo "    Year:            $year"
  echo "    Audio Channels:  $channels"
  echo "    Quality:         $quality"
  echo "    Input File:      $file $ISIZE"
  echo "  - Finished:        `date`"
  echo
  echo "  * MOVIE COMPLETE!  $dest_file $OSIZE"
}

printTvDetails(){
  ISIZE=$(ls -lh "$1" | awk '{print $5}')
  OSIZE=$(ls -lh "$2" | awk '{print $5}')

  echo "  - Details:"
  echo "    DIR:             $DIR"
  echo "    NZB_FILE:        $NZB_FILE"
  echo "    NAME:            $NAME"
  echo "    NZB_ID:          $NZB_ID"
  echo "    CATEGORY:        $CATEGORY"
  echo "    GROUP:           $GROUP"
  echo "    STATUS:          $STATUS"
  echo "    Dest Folder:     $tv_dest_folder"
  echo "    Dest File:       $dest_file"
  echo "    Show Name:       $show_name"
  echo "    Season:          $season"
  echo "    Episode:         $episode"
  echo "    Episode Name:    $episode_name"
  echo "    Year:            $year"
  echo "    Month:           $month"
  echo "    Day:             $day"
  echo "    Audio Channels:  $channels"
  echo "    Quality:         $quality"
  echo "    Input File:      $file $ISIZE"
  echo "  - Finished:        `date`"
  echo
  echo "  * TV COMPLETE!     $dest_file $OSIZE"
}

tagMovie(){
  if [[ $enable_atomicparsley -eq 1 ]]; then
    # $1 = atomicFile_XXX.m4v
    echo "  * TAGGING file with metadata" 
    # remove existing metadata
    echo "  - Removing Existing Metadata"
    $atomicparsley "$1" --metaEnema --overWrite
    echo
    sleep 2
    # if artwork is available locally then tag.
    if [[ -e $(find "$movie_artwork" -name "${NAME}.jpg") ]]; then
      echo "  - AtomicParsley!!!  tagging w/local artwork."
      echo "atomicparsley $1 --genre Movie --stik Movie --title=$title --year=$year --artwork ${movie_artwork}${NAME}.jpg --overWrite > /dev/null 2>&1"
      $atomicparsley "$1" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --artwork "${movie_artwork}${NAME}.jpg" --overWrite > /dev/null 2>&1
    else
      # just tag
      echo "  - AtomicParsley!!!  tagging w/o artwork."
      echo "atomicparsley $1 --genre Movie --stik Movie --title=$title --year=$year --overWrite > /dev/null 2>&1"
      $atomicparsley "$1" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --overWrite > /dev/null 2>&1
    fi

    if [[ $? != 0 ]]; then
      echo "!!! LOGGING ERROR while tagging"
      logError $dest_file
    fi    
  fi
}

tagTv(){
  if [[ $enable_atomicparsley -eq 1 ]]; then
    # $1 = atomicFile_XXX.m4v
    echo "  * TAGGING file with metadata" 
    # remove existing metadata
    echo "  - Removing Existing Metadata"
    $atomicparsley "$1" --metaEnema --overWrite
    echo
    sleep 2

    show_name="$2"
    episode_name="$3"
    episode="$4"
    season="$5"
    # get artwork from epguides.com
    epguidesartwork=$(echo $show_name | sed 's/ *//g')
    wget -N http://epguides.com/$epguidesartwork/cast.jpg > /dev/null 2>&1
    echo
    echo "  - Retrieved Artwork from http://epguides.com"
    
    # if artwork is available locally then tag.
    if [[ -e $(find "$tv_artwork" -name "${show_name}.jpg") ]]; then
      echo "  - AtomicParsley!!!  tagging w/local artwork."
      $atomicparsley "$1" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "${tv_artwork}${show_name}.jpg" --overWrite > /dev/null 2>&1
    
    # else get artwork if available from epguides.com and tag.
    elif [[ -e $(find . -name "cast.jpg") ]]; then
      echo "  - AtomicParsley!!!  tagging w/epguides.com artwork."
      $atomicparsley "$1" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "cast.jpg" --overWrite > /dev/null 2>&1
    
    # otherwise tag without artwork.
    else
      echo "  - AtomicParsley!!!  tagging w/o artwork."
      $atomicparsley "$1" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --overWrite > /dev/null 2>&1
    fi

    if [[ $? != 0 ]]; then
      echo "!!! LOGGING ERROR while tagging"
      logError $dest_file
    fi  
  fi
}

moveTranscoded(){
  # $1 = atomicFile_XXX.m4v
  dest_file="$2"
  dest_folder="$3"
  echo "  * Moving transcoded file to folder."
  echo "  - mv $1 \"$dest_folder$dest_file\""

  # curly braces breaks mv
  mv "$1" "$dest_folder$dest_file"

  if [[ $? -ne 0 ]]; then
    echo "$?"
    echo "!!! ERROR, mv exit code"
    date
    exit 1
  fi
}

moveOriginal(){
  # move the original downloaded file to a folder.
  # don't fail if none is found.  e.g. re-encoding (moved) existing .m4v
  echo "  * Moving original downloaded file to folder."
  echo "  - mv \"$file\" \"$postproc_dest_folder$file\""
  # curly braces breaks mv
  mv "$file" "$postproc_dest_folder$file"

  if [[ $? -ne 0 ]]; then
    echo "$?"
    echo "!!! ERROR, mv exit code"
    date
    exit 1
  fi
}

findArtwork(){
  # $1 = $movie_artwork
  # find existing artwork and store
  # TODO add more media types
  find . -type f -name '*.jpg' -exec mv '{}' "${1}/${NAME}.jpg" \;
}

consolidateFiles(){
  # consolidate all files into the main processing folder
  echo "  - Consolidating files in $DIR"
  find "$DIR" -mindepth 2 -type f -exec mv -i '{}' "$DIR" ';'

  # TODO this may no longer be relevant
  if [[ $? -ne 0 ]]; then
    echo "  - mv errors above are ok."
    echo
  fi
}

tvRenamer(){
  # https://github.com/meermanr/TVSeriesRenamer
  # TODO remove dependency on tvrenamer.pl
  if [[ $enable_tvrenamer -eq 0 ]]; then
      break
  fi
  # if standard SxxExx episode format, improve SABnzbd renaming by using tvrenamer.pl
  echo "  * RENAMING the file with tvrenamer.pl"
  rm *.[uU][rR][lL]
  # tvrenamer.pl sometimes hangs. background the cmd and kill it after X seconds.
  /usr/local/bin/tvrenamer.pl --debug --noANSI --nogroup --unattended --gap=" - " --separator=" - " --pad=2 --scheme=SXXEYY --include_series &
  TASK_PID=$!
  sleep 10
  kill -9 $TASK_PID
  echo "  - sometimes we kill tvRenamer.pl on purpose"
  echo
}

tvNamer(){
  # https://github.com/dbr/tvnamer
  if [[ $enable_tvrenamer -eq 1 ]]; then
    echo "  * RENAMING the file with tvnamer"
    /usr/local/bin/tvnamer --batch -q *
  fi
}

mkIsofs(){
  # TODO QA this
  # find VIDEO_TS folder and files
  if [[ -e $(find . \( ! -regex '.*/\..*' \) -type f -name "VIDEO_TS.IFO") ]]; then
    echo "VIDEO_TS Found, converting to an ISO"
    IFO=$(find . \( ! -regex '.*/\..*' \) -type f -name "VIDEO_TS.IFO")
    echo "  - folder/file: \"$IFO\""
    VIDEOTS=$(echo $IFO | sed -r 's/[vV][iI][dD][eE][oO][_][tT][sS][.][iI][fF][oO].*//g')
    VIDEOTSROOT=$(echo $VIDEOTS | sed -r 's/[vV][iI][dD][eE][oO][_][tT][sS].*//g')
    mkisofs -input-charset iso8859-1 -dvd-video -o "${DIR}/atomicFile.iso" "$VIDEOTSROOT" > /dev/null 2>&1
    
    if [[ $? -ne 0 ]]; then
      echo "$?"
      echo "!!! ERROR, mkisofs exit code"
      date
      exit 1
    fi

    echo "  - Conversion to ISO complete"
    # TODO QA this
    # rm -R ${VIDEOTSROOT}
    echo "  - Deleted VIDEO_TS folder"
    echo
  fi
}

checkSplitAvi(){
  # find split .avi files
  # TODO QA this
  # -print -quit = return one result
  if [[ -f $(find . -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*(cd1|cd2)\.(avi)' -print -quit) ]]; then
    echo "  - 2 CD files found"
    file=$(find . -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*(cd1|cd2)\.(avi)' -print -quit)
    file=$(echo $file | sed -r 's/^\.\///g') # strip the leading "./" from the find results
    NAME=$(echo ${file%.*})
    NAME=$(echo $NAME | sed -r 's/[cC][dD][12].*//g' | sed -r 's/[- .]{1,}$//g') # strip CDx and trailing characters from $NAME
    avimerge -o "${NAME}.avi" -i *{CD1,cd1}.avi *{CD2,cd2}.avi > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "$?"
      echo "!!! ERROR, avimerge exit code"
      date
      exit 1
    fi

    echo "  - AVImerge!!! complete"
    # TODO QA this
    find . -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*(cd1|cd2)\.(avi)' -exec mv '{}' "$unwatched_dest_folder" ';'
    echo
  fi
}

cleanupFilename(){
  show_name="$1"
  episode_name="$2"
  # convert double space to single
  show_name=$(echo $show_name | sed -r 's/\s\s/\s/g')
  # strip trailing " -"   
  show_name=$(echo $show_name | sed -r 's/[- .]{1,}$//g')
  episode_name=$(echo $episode_name | sed -r 's/\s\s/\s/g')
  # captialize first character of words
  show_name=$(echo $show_name | sed -e 's/\b\(.\)/\u\1/g')
  # strip leading characters
  episode_name=$(echo $episode_name | sed -r 's/^[- .]{1,3}//g')
  # strip everything after " - HDTV"
  # episode_name=$(echo $episode_name | sed -r 's/[hH][dD][tT][vV].*//g' | sed -r 's/ *$//g')
  # strip WEBRIP
  # episode_name=$(echo $episode_name | sed -r 's/[wW][eE][bB][rR][iI][pP].*//g' | sed -r 's/ *$//g')
  # strip 1080P
  # episode_name=$(echo $episode_name | sed -r 's/1080[pP].*//g' | sed -r 's/ *$//g')
  # strip 720P
  # episode_name=$(echo $episode_name | sed -r 's/720[pP].*//g' | sed -r 's/ *$//g')
  # strip PROPER
  # episode_name=$(echo $episode_name | sed -r 's/PROPER.*//g' | sed -r 's/ *$//g')
  # strip ending characters
  episode_name=$(echo $episode_name | sed -r 's/[- .]{1,}$//g')
  # captialize first character of words
  episode_name=$(echo $episode_name | sed -e 's/\b\(.\)/\u\1/g')
}

checkIfOpen(){
  check_file="$1"
  while :
  do
    if ! [[ `lsof -- "$1" ` ]]
    then
      break
    fi
    sleep 3
  done
}

logError(){
  logArray+=("$1")
}

printError(){
  if [ ${#logArray[@]} -ne 0 ]; then
    echo "!!! ERRORS tagging files:"
    ( IFS=$'\n'; echo "${logArray[*]}" )
    echo "!!! COMPLETED with errors"
  fi
}

# above are all functions
# below is execution

if [[ "$CATEGORY" != "sonarr" ]] && [[ "$CATEGORY" != "radarr" ]]; then
  # execution via shell or SABNZBD
  cd "$DIR"
  if [[ $? -ne 0 ]]; then
    echo "!!! ERROR, cd '$DIR'"
    # sometimes SABNZBD leaves _UNPACK_$DIR
    # LDIR=$(echo $DIR | grep -Eo '[^/]+/?$')
    # NDIR=$(echo $DIR | sed -e "s%$LDIR%%")
    # DIR="$NDIR/_UNPACK_$LDIR"
    # echo "!!! TRYING, cd '$NDIR/_UNPACK_$LDIR'"
    # cd "$DIR"
    # if [[ $? -ne 0 ]]; then
    #   echo "$?"
    #   echo "!!! ERROR, cd '$NDIR/_UNPACK_$LDIR'"
    #   date
    #   exit 1
    # fi
  fi
fi

echo "START! `date`"

# BEGIN movies

if [[ "$CATEGORY" = "movies" ]]; then
  # regex matches: movie name (2013).xyz
  # regex="(.*) \(([0-9]{4})\).*"

  # matches: movie name (2013) [hdtv-720p].xyz
  regex="(.*) \(([0-9]{4})\)[- .]{0,3}(\[.*\])?.*"

  mkIsofs
  consolidateFiles

  # find media file larger than 100MB
  file=$(find . -maxdepth 1 -type f -size +100000k -regextype "posix-extended" -iregex ".*\.($media_types)" ! -name "atomicFile*.m4v")
  # exit if no media files found
  if [[ ! -f "$file" ]]; then
    echo "!!! NO media file found"
    date
    exit 1
  fi

  echo
  echo "  - Discovered Media File:"
  file=$(echo $file | sed -r 's/^\.\///g') # strip the leading "./" from the find results
  NAME=$(echo ${file%.*})
  EXT=${file##*.}
  ISIZE=$(ls -lh "$file" | awk '{print $5}')
  echo "    $NAME.$EXT $ISIZE"
  # destination filename
  dest_file="${file%.*}.m4v"

  if [[ $NAME =~ $regex ]]; then
    echo "  - REGEX detected Movie,"
    echo "  - $regex"
    echo

    # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
    year=${BASH_REMATCH[2]}
    quality=${BASH_REMATCH[3]}
    # customize movie title tag for atomicparsley
    # title =${BASH_REMATCH[1]} # = "Movie"
    title=${NAME} # NAME = "Movie (2013)"
    # strip CD1 from $title
    title=$(echo $title | sed -r 's/[- ][cC][dD][12].*//g' | sed 's/ *$//g')
    # captialize first character of words
    title=$(echo $title | sed -e 's/\b\(.\)/\u\1/g')

  else
    echo "!!! regex ERROR,"
    echo "  - $regex"
    echo "  - $file"
    date
    exit 1
  fi

  checkSplitAvi
  sleep 2
  findArtwork "$movie_artwork"
  sleep 2
  # when running via shell check for tag switch
  if [[ $8 != "tag" ]]; then
    encodeMovie "atomicFile.m4v"
    sleep 2
  elif [[ $8 -eq "tag" ]]; then
    mv "$file" "atomicFile.m4v"
    sleep 2
  fi
    
  ls -l "atomicFile.m4v" > /dev/null 2>&1
    
  if [[ $? != 0 ]]; then
    echo "!!! ERROR, atomicFile.m4v missing"
    date
    exit 1
  fi
  checkIfOpen "atomicFile.m4v"
  tagMovie "atomicFile.m4v"
  printMovieDetails "$file" "$dest_file"
  checkIfOpen "atomicFile.m4v"
  moveTranscoded "atomicFile.m4v" "$dest_file" "$movie_dest_folder"
  checkIfOpen "$file"
  moveOriginal
  printError

fi

# END movies

# BEGIN tv

if [[ "$CATEGORY" = "tv" ]]; then
  # regex matches: show name - s01e02 - episode name.xyz
  # regex="(.*?)[- .]{1,3}[sS]([0-9]{1,4})[eE]([0-9]{1,2})[- .]{0,3}(.*?)\..*$"

  # regex matches: show name - s01e02 - episode name [hdtv-720p].xyz
  regex="(.*?)[- .]{1,3}[sS]([0-9]{1,4})[eE]([0-9]{1,2})[- .]{0,3}(.*?)[- .]{0,3}(\[.*\])?\..*$"

  # regex matches: the daily show - 2013-08-01 - episode name.xyz
  # regex_dated="(.*)[- .]{3}([0-9]{4})[- .]([0-9]{2})[- .]([0-9]{2})[- .]{3}(.*).*"

  # regex matches: the daily show - 2013-08-01 - episode name [hdtv-720p].xyz
  regex_dated="(.*)[- .]{3}([0-9]{4})[- .]([0-9]{2})[- .]([0-9]{2})[- .]{0,3}(.*?)[- .]{0,3}(\[.*\])?\..*$"

  # custom processing for shows
  # regex matches: the soup - 2013-08-01 - episode name.xyz
  regex_soup="([tT][hH][eE] [sS][oO][uU][pP]) - ([0-9]{4})-([0-9]{2})-([0-9]{2}) - (.*)\..*"

  tvNamer

  COUNTER=0
  while IFS= read -r -d '' file; do
    let COUNTER=COUNTER+1
    file=$(echo $file | sed -r 's/^\.\///g') # strip the leading "./" from the find results
    NAME=$(echo ${file%.*})
    EXT=${file##*.}
    ISIZE=$(ls -lh "$file"  | awk '{print $5}')
    echo
    echo "  - Discovered media file # $COUNTER @ `date +"%T %Y-%m-%d"`"
    echo "    $NAME.$EXT $ISIZE"
  
    if [[ $file =~ $regex_soup ]]; then
      echo "  - REGEX detected The Soup,"
      echo "  - $regex_soup"
      echo "  - $file"
  
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      year=${BASH_REMATCH[2]}
      month=${BASH_REMATCH[3]}
      # strip leading 0 from month
      # month=$(echo $month | sed -r 's/^0//g')
      day=${BASH_REMATCH[4]}
      quality=${BASH_REMATCH[5]}
      # use the year as the season for dated shows
      season=$year
      episode=${year}${month}${day}
      cleanupFilename "$show_name" x # function expects two variables
      echo "  - \$show_name     = $show_name"
      echo "  - \$year/\$season  = $year"
      echo "  - \$month         = $month"
      echo "  - \$day           = $day"
      echo "  - \$episode       = $episode"
      echo "  - \$channels      = $channels"
      echo "  - \$quality       = $quality"
      echo
  
      # destination filename
      if [[ ! -z "$episode_name" ]]; then
        dest_file="${show_name} - ${year}-${month}-${day} - ${episode_name}.m4v"    
      else    
        dest_file="${show_name} - ${year}-${month}-${day}.m4v"    
      fi
  
    elif [[ $file =~ $regex_dated ]]; then
      echo "  - REGEX detected Dated TV Show,"
      echo "  - $regex_dated"
      echo "  - $file"
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      year=${BASH_REMATCH[2]}
      month=${BASH_REMATCH[3]}
      # strip leading 0 from month
      # month=$(echo $month | sed -r 's/^0//g')
      day=${BASH_REMATCH[4]}
      episode_name=${BASH_REMATCH[5]}
      quality=${BASH_REMATCH[6]}
      # use the year as the season for dated shows
      season=$year
      episode=${year}${month}${day}
      cleanupFilename "$show_name" "$episode_name"
      echo "  - \$show_name     = $show_name"
      echo "  - \$year/\$season  = $year"
      echo "  - \$month         = $month"
      echo "  - \$day           = $day"
      echo "  - \$episode       = $episode"
      echo "  - \$episode_name  = $episode_name"
      echo "  - \$channels      = $channels"
      echo "  - \$quality       = $quality"
      echo
  
      # TODO add handling for $quality naming
      # destination filename
      if [[ ! -z "$episode_name" ]]; then
        dest_file="${show_name} - ${year}-${month}-${day} - ${episode_name}.m4v"    
      else    
        dest_file="${show_name} - ${year}-${month}-${day}.m4v"    
      fi
  
    elif [[ $file =~ $regex ]]; then
      echo "  - REGEX detected TV Show,"
      echo "  - $regex | http://regexr.com/3g2ib"
      echo "  - $file"
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      season=${BASH_REMATCH[2]}
      episode=${BASH_REMATCH[3]}
      episode_name=${BASH_REMATCH[4]}
      quality=${BASH_REMATCH[5]}
      cleanupFilename "$show_name" "$episode_name"
      echo "  - \$show_name     = $show_name"
      echo "  - \$season        = $season"
      echo "  - \$episode       = $episode"
      echo "  - \$episode_name  = $episode_name"
      echo "  - \$channels      = $channels"
      echo "  - \$quality       = $quality"
      echo
  
      # TODO add handling for $quality naming
      # destination filename
      if [[ ! -z "$episode_name" ]]; then
        dest_file="${show_name} - S${season}E${episode} - ${episode_name}.m4v"
      else    
        dest_file="${show_name} - S${season}E${episode}.m4v"
      fi
  
    else
      echo "!!! REGEX error,"
      echo "  - $regex"
      echo "!!! skipping $file"
      continue
    fi

    # TODO improve this
    # skip file if it exists in the destination folder
    # if [[ -e "${tv_dest_folder}${dest_file}" ]]; then
    #   echo "!!! a M4V with the same name already exists,"
    #   echo "!!! skipping $file"
    #   continue
    # fi

    # when running via shell check for tag switch
    if [[ $8 != "tag" ]]; then
      encodeTv "atomicFile.m4v"
      sleep 2
    elif [[ $8 -eq "tag" ]]; then
      mv "$file" "atomicFile.m4v"
      sleep 2
    fi
    
    ls -l "atomicFile.m4v" > /dev/null 2>&1
    
    if [[ $? != 0 ]]; then
      echo "!!! ERROR, atomicFile.m4v missing"
      date
      exit 1
    fi

    checkIfOpen "atomicFile.m4v"
    tagTv "$atomicFile" "$show_name" "$episode_name" "$episode" "$season"
    printTvDetails "$file" "$dest_file"
    checkIfOpen "atomicFile.m4v"
    moveTranscoded "atomicFile.m4v" "$dest_file" "$tv_dest_folder"
    if [[ -z $8 ]] || [[ $8 -ne "tag" ]]; then
      checkIfOpen "$file"
      moveOriginal
    fi
  done < <(find . -maxdepth 1 -type f -size +30000k -regextype "posix-extended" -iregex ".*\.($media_types)" ! -name "atomicFile*.m4v" -print0)

  printError

# END tv

fi

# BEGIN sonarr

if [[ "$CATEGORY" = "sonarr" ]]; then
  file="$sonarr_episodefile_path" # /media/TV/Show Name (2017"/Season 01/Show Name (2017) - S01E01 - Episode 1.mkv
  DIR=$(dirname "$file")
  file=$(basename "$file")
  series_path="$sonarr_series_path" # /media/TV/Show Name (2017)
  series_type="$sonarr_series_type" # Anime, Daily, or Standard
  show_name="$sonarr_series_title" # Show Name (2017)
  season="$sonarr_episodefile_seasonnumber" # 1
  episode="$sonarr_episodefile_episodenumbers" # 1
  episode_name="$sonarr_episodefile_episodetitles" #
  episode_date="$sonarr_episodefile_episodeairdates" # 2017-05-31
  file_id="$sonarr_episodefile_id" # 123
  atomicFile="atomicFile_$file_id.m4v"
  #
  scene_name="$sonarr_episodefile_scenename" # "Show.Name.US.S01E01.720p.HDTV.x265-AMZN
  air_date="$sonarr_episodefile_episodeairdatesutc" # 5/31/2017 5:00:00 PM
  relative_path="$sonarr_episodefile_relativepath" # Season 01/Show Name (2017" - S01E01 - Episode 1.mkv
  event_type="$sonarr_eventtype" # Download
  series_id="$sonarr_series_id" # 123
  tvdb_id="$sonarr_series_tvdbid" # 123
  file_id="$sonarr_episodefile_id" # 123
  release_group="$sonarr_episodefile_releasegroup" # AMZN
  quality="$sonarr_episodefile_quality" # HDTV-720p
  quality_version="$sonarr_episodefile_qualityversion" # 1

  if [[ $series_type = "Standard" ]]; then
    echo "  - Detected TV Show,"
    echo "  - $file"
    echo "  - \$show_name     = $show_name"
    echo "  - \$season        = $season"
    echo "  - \$episode       = $episode"
    echo "  - \$episode_name  = $episode_name"
    echo "  - \$quality       = $quality"
    echo
  elif [[ $series_type = "Daily" ]]; then
    # use the year as the season for dated shows
    season=$(echo $episode_date | sed -r 's/-[0-9]{2}-[0-9]{2}//g')
    echo "  - Detected Dated TV Show,"
    echo "  - $file"
    echo "  - \$show_name     = $show_name"
    echo "  - \$season        = $season"
    echo "  - \$episode       = $episode"
    echo "  - \$episode_name  = $episode_date"
    echo "  - \$quality       = $quality"
    echo
  else
    echo "!!! ERROR, \$series_type = $series_type"
    echo "!!! skipping $file"
    date
    exit 1
  fi

  cd "$DIR"
  if [[ $? -ne 0 ]]; then
    echo "!!! ERROR, cd '$DIR'"
    exit 1
  fi

  checkIfOpen "$file"
  encodeTv "$atomicFile"
  checkIfOpen "$atomicFile"
  tagTv "$atomicFile" "$show_name" "$episode_name" "$episode" "$season"
  dest_file="$(basename "$file" | sed 's/\.[^.]*$//').m4v"
  # mv "$atomicFile" "$dest_file.m4v"
  # moveTranscoded "$atomicFile" "$dest_file.m4v" "$tv_dest_folder"
  # if move successful, remove original
  # if [[ $? -eq 0 ]]; then
  #   rm "$file"
  # notify sonarr
  #   # curl -i -X POST -H "Content-Type:application/json" http://localhost:8989/api/command/?apikey=3a8a51773183422c9a511d0c9e733fb6 -d '{"name":"DownloadedEpisodesScan"}'
  # fi
  printTvDetails "$file" "$atomicFile"
  # remove original file to avoid name collision
  rm "$file"
  checkIfOpen "$atomicFile"
  mv "$atomicFile" "$dest_file"
  printError
fi

# END sonarr

# BEGIN radarr

if [[ "$CATEGORY" = "radarr" ]]; then
  file="$radarr_moviefile_path"
  DIR=$(dirname "$file")
  file=$(basename "$file")
  movie_path="$radarr_movie_path"
  movie_name="$radarr_movie_title"
  scene_name="$radarr_moviefile_scenename"
  relative_path="$radarr_moviefile_relativepath"
  event_type="$radarr_eventtype"
  series_id="$radarr_series_id"
  file_id="$radarr_moviefile_id"
  release_group="$radarr_moviefile_releasegroup"
  quality="$radarr_moviefile_quality"
  quality_version="$radarr_moviefile_qualityversion"
  atomicFile="atomicFile_$file_id.m4v"

  cd "$DIR"
  if [[ $? -ne 0 ]]; then
    echo "!!! ERROR, cd '$DIR'"
    exit 1
  fi

  checkIfOpen "$file"
  encodeMovie "$atomicFile"
  checkIfOpen "$atomicFile"
  tagMovie "$atomicFile"
  dest_file="$(basename "$file" | sed 's/\.[^.]*$//').m4v"
  printMovieDetails "$file" "$atomicFile"
  # remove original file to avoid name collision
  rm "$file"
  checkIfOpen "$atomicFile"
  mv "$atomicFile" "$dest_file"
  printError
fi

# END radarr
