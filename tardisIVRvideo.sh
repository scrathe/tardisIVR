#!/bin/bash

# Home; https://github.com/scrathe/tardisIVR
# Documentation; https://github.com/scrathe/tardisIVR/blob/master/README.md
# Settings; https://github.com/scrathe/tardisIVR/blob/master/SETTINGS.md
#
# BIG thanks to the original author(s), especially the BASH/OSX community who helped me achieve my goals.
# author 1) https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
# author 2+) ??? (the scores of unnamed authors)
#
# some applications you need:
# HandbrakeCLI (transcodes video) http://handbrake.fr/
# AtomicParsley (tags video files with info and cover art) http://atomicparsley.sourceforge.net
# avimerge (join .avi files) http://manpages.ubuntu.com/manpages/dapper/man1/avimerge.1.html
# MEncoder (alternative method to join .avi files) https://help.ubuntu.com/community/MEncoder
# mkisofs (convert VIDEO_TS folders to .iso format) http://manpages.ubuntu.com/manpages/gutsy/man8/mkisofs.8.html
# tvrenamer.pl (fetches episode names for SxxExx TV Shows) http://www.robmeerman.co.uk/coding/file_rename

# sample option 'Ignore Samples' in Sabnzbd | Config | Switches, must be set to 'Do not download'

# user definable locations
# ensure ALL directories end with '/'

# Movie transcoded file destination
movie_dest_folder="/media/tardis-x/downloads/epic/postprocessing/couchpotato/"

# Movie original downloaded file destination
# this script keeps the original files in case something goes wrong.  empty this dir regularly.
unwatched_dest_folder="/media/tardis-x/downloads/epic/trash/"

# Movie artwork location if you have it
# files must be formatted to match the Show Name and have a jpg extension eg: "The Show Name.jpg"
movie_artwork="/media/tardis-x/downloads/epic/artwork/movies/"

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
tv_artwork="/media/tardis-x/downloads/epic/artwork/tv/"

# TV Show HandBrake preset
tv_preset="AppleTV"

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

# stops error printing in loop if there are no video files in the folder
shopt -s nullglob

encodeMovie(){
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
      echo "  - Transcoding!!! BlueRay,"
      echo handbrake-cli -O -i \"$M2TS\" -o "atomicFile.m4v" --preset="$movie_preset"
      echo
      START=$(date +%s)
      handbrake-cli -O -i "$M2TS" -o "atomicFile.m4v" --preset="$movie_preset" > /dev/null 2>&1

      if [[ $? -ne 0 ]]; then
        echo "$?"
        echo "!!! ERROR, HandBrake exit code"
        date
        exit 1
      fi

      END=$(date +%s)
      echo "  - Time Elapsed: "$((END-START)) | awk '{print int($1/60)":"int($1%60)}'
    fi

  # if not BlueRay just transcode
  else
    echo "  - Transcoding!!!"
    echo handbrake-cli -O -i \"$file\" -o "atomicFile.m4v" --preset="$movie_preset"
    echo
    START=$(date +%s)
    handbrake-cli -O -i "$file" -o "atomicFile.m4v" --preset="$movie_preset" > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "$?"
      echo "!!! ERROR, HandBrake exit code"
      date
      exit 1
    fi

    END=$(date +%s)
    echo "  - Time Elapsed: "$((END-START)) | awk '{print int($1/60)":"int($1%60)}'
  fi

  if [[ $iso_detected -eq 1 ]]; then
    echo "  - un-mounting .iso"
    sudo umount /media/iso
    echo
  fi

  # check output file created by handbrake
  ls -l "atomicFile.m4v" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "!!! ERROR, HandBrake atomicFile.m4v missing"
    date
    exit 1
  fi
}

encodeTv(){
  # convert using handbrake
  echo "  - Transcoding!!!"
  echo handbrake-cli -O -i \"$file\" -o "atomicFile.m4v" --preset="$tv_preset"
  echo
  START=$(date +%s)
  handbrake-cli -O -i "$file" -o "atomicFile.m4v" --preset="$tv_preset" > /dev/null 2>&1
  # " > /dev/null 2>&1" at the end of the line directs output from HandBrake away from the script log

  if [[ $? != 0 ]]; then
    echo "$?"
    echo "!!! ERROR, HandBrake exit code"
    date
    exit 1
  fi

  END=$(date +%s)
  echo "  - Time Elapsed: "$((END-START)) | awk '{print int($1/60)":"int($1%60)}'
}

printMovieDetails(){
  OSIZE=$(ls -lh "${movie_dest_folder}${movie_dest_file}" | awk '{print $5}')

  echo "  - Details:"
  echo "    DIR:          $DIR"
  echo "    NZB_FILE:     $NZB_FILE"
  echo "    NAME:         $NAME"
  echo "    NZB_ID:       $NZB_ID"
  echo "    CATEGORY:     $CATEGORY"
  echo "    GROUP:        $GROUP"
  echo "    STATUS:       $STATUS"
  echo "    Dest Folder:  $movie_dest_folder"
  echo "    Dest File:    $movie_dest_file"
  echo "    Title:        $title"
  echo "    Year:         $year"
  echo "    Input File:   $file $ISIZE"
  echo
  date
  echo "  - COMPLETED!    $movie_dest_file $OSIZE"
}

printTvDetails(){
  OSIZE=$(ls -lh "${tv_dest_folder}${tv_dest_file}" | awk '{print $5}')

  echo "  - Details:"
  echo "    DIR:          $DIR"
  echo "    NZB_FILE:     $NZB_FILE"
  echo "    NAME:         $NAME"
  echo "    NZB_ID:       $NZB_ID"
  echo "    CATEGORY:     $CATEGORY"
  echo "    GROUP:        $GROUP"
  echo "    STATUS:       $STATUS"
  echo "    Dest Folder:  $tv_dest_folder"
  echo "    Dest File:    $tv_dest_file"
  echo "    Show Name:    $show_name"
  echo "    Season:       $season"
  echo "    Episode:      $episode"
  echo "    Episode Name: $episode_name"
  echo "    Year:         $year"
  echo "    Month:        $month"
  echo "    Day:          $day"
  echo "    Input File:   $file $ISIZE"
  echo
  date
  echo "  - COMPLETED!    $tv_dest_file $OSIZE"
}

tagMovie(){
  # remove existing metadata
  echo "  - Removing Existing Metadata"
  atomicparsley "atomicFile.m4v" --metaEnema --overWrite
  # if artwork is available locally then tag.
  if [[ -e $(find "$movie_artwork" -name "${NAME}.jpg") ]]; then
    echo "  - AtomicParsley!!!  tagging w/local artwork."
    echo "atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --artwork "${movie_artwork}${NAME}.jpg" --overWrite > /dev/null 2>&1"
    atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --artwork "${movie_artwork}${NAME}.jpg" --overWrite > /dev/null 2>&1
  else
    # just tag
    echo "  - AtomicParsley!!!  tagging w/o artwork."
    echo "atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --overWrite > /dev/null 2>&1"
    atomicparsley "atomicFile.m4v" --genre "Movie" --stik "Movie" --title="$title" --year="$year" --overWrite > /dev/null 2>&1
  fi

  # this broke one time so i'm disabling it :)
  # if [ $? != 0 ]; then
  #  echo "$?"
  #  echo "!!! ERROR, AtomicParsley exit code"
  #  date
  #  exit 1
  # fi
}

tagTv(){
  # remove existing metadata
  echo "  - Removing Existing Metadata"
  atomicparsley "atomicFile.m4v" --metaEnema --overWrite

  show_name="$1"
  episode_name="$2"
  episode="$3"
  season="$4"
  # get artwork from epguides.com
  epguidesartwork=$(echo $show_name | sed 's/ *//g')
  wget -N http://epguides.com/$epguidesartwork/cast.jpg > /dev/null 2>&1
  echo "  - Retrieved Artwork from http://epguides.com"
  
  # if artwork is available locally then tag.
  if [[ -e $(find "$tv_artwork" -name "${show_name}.jpg") ]]; then
    echo "  - AtomicParsley!!!  tagging w/local artwork."
    atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "${tv_artwork}${show_name}.jpg" --overWrite > /dev/null 2>&1
  
  # else get artwork if available from epguides.com and tag.
  elif [[ -e $(find . -name "cast.jpg") ]]; then
    echo "  - AtomicParsley!!!  tagging w/epguides.com artwork."
    atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --artwork "cast.jpg" --overWrite > /dev/null 2>&1
  
  # otherwise tag without artwork.
  else
    echo "  - AtomicParsley!!!  tagging w/o artwork."
    atomicparsley "atomicFile.m4v" --genre "TV Shows" --stik "TV Show" --TVShowName "$show_name" --TVEpisode "$episode_name" --description "$episode_name" --TVEpisodeNum "$episode" --TVSeason "$season" --title "$show_name" --overWrite > /dev/null 2>&1
  fi

  if [[ $? != 0 ]]; then
    echo "$?"
    echo "!!! ERROR, AtomicParsley exit code"
    date
    exit 1
  fi

  # sleep a bit
  sleep 3
}

moveTranscoded(){
  dest_file="$1"
  dest_folder="$2"
  echo $1
  echo $2
  echo $dest_file
  echo $dest_folder
  echo "  - Moving transcoded file to folder."
  echo "  - mv ${dest_file} ${dest_folder}"

  mv "atomicFile.m4v" "${dest_folder}${dest_file}"

  if [[ $? -ne 0 ]]; then
    echo "$?"
    echo "!!! ERROR, mv exit code"
    date
    exit 1
  fi

  # sleep a bit
  sleep 3
}

moveOriginal(){
  # move the original downloaded file to a folder.
  # don't fail if none is found.  e.g. re-encoding (moved) existing .m4v
  echo "  - Moving original downloaded file to folder."
  echo "  - mv $file $postproc_dest_folder$file"
  mv "$file" "${postproc_dest_folder}${file}"

  if [[ $? -ne 0 ]]; then
    echo "  - mv errors above are ok."
    echo
  fi

  # sleep a bit
  sleep 3
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
  # if standard SxxExx episode format, improve SABnzbd renaming by using tvrenamer.pl
  if [[ $CATEGORY = "tv" && $NAME =~ $regex  ]]; then
    echo "  - Renaming the file with tvrenamer.pl"
    rm *.[uU][rR][lL]
    # tvrenamer.pl sometimes hangs. background the cmd and kill it after X seconds.
    /usr/local/bin/tvrenamer.pl --debug --noANSI --nogroup --unattended --gap=" - " --separator=" - " --pad=2 --scheme=SXXEYY --include_series &
    TASK_PID=$!
    sleep 10
    kill -9 $TASK_PID
    echo
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
  # avimerge works!
  # mencoder untested
  # TODO improve this
  # -print -quit = return one result
  if [[ -f $(find . -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*(cd1|cd2)\.(avi)' -print -quit) ]]; then
    echo "  - 2 CD files found"
    file=$(find . -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*(cd1|cd2)\.(avi)' -print -quit)
    NAME=$(echo ${file%.*} | sed -r 's/^\.\///g') # strip the leading "./" from the find results
    NAME=$(echo $NAME | sed -r 's/[cC][dD][12].*//g' | sed -r 's/[- .]{1,}$//g') # strip CDx and trailing characters from $NAME
    # mencoder on linux requires a lot of dependencies.  let's try other methods more suitable for a headless server.
    # mencoder -forceidx -ovc copy -oac copy *{CD1,cd1}.avi *{CD2,cd2}.avi -o "$NAME.avi" > /dev/null 2>&1
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
  episode_name=$(echo $episode_name | sed -r 's/\s\s/\s/g')
  # captialize first character of words
  show_name=$(echo $show_name | sed -e 's/\b\(.\)/\u\1/g')
  # strip leading characters
  episode_name=$(echo $episode_name | sed -r 's/^[- .]{1,3}//g')
  # strip everything after " - HDTV"
  episode_name=$(echo $episode_name | sed -r 's/[hH][dD][tT][vV].*//g' | sed -r 's/ *$//g')
  # strip WEBRIP
  episode_name=$(echo $episode_name | sed -r 's/[wW][eE][bB][rR][iI][pP].*//g' | sed -r 's/ *$//g')
  # strip 1080P
  episode_name=$(echo $episode_name | sed -r 's/1080[pP].*//g' | sed -r 's/ *$//g')
  # strip 720P
  episode_name=$(echo $episode_name | sed -r 's/720[pP].*//g' | sed -r 's/ *$//g')
  # strip PROPER
  episode_name=$(echo $episode_name | sed -r 's/PROPER.*//g' | sed -r 's/ *$//g')
  # strip ending characters
  episode_name=$(echo $episode_name | sed -r 's/[- .]{1,}$//g')
  # captialize first character of words
  episode_name=$(echo $episode_name | sed -e 's/\b\(.\)/\u\1/g')
}

# above are all functions
# below is execution

cd "$DIR"
if [[ $? -ne 0 ]]; then
  echo "$?"
  echo "!!! ERROR, cd '$DIR'"
  date
  exit 1
fi

  echo "START! `date`"

# BEGIN movies

if [[ $CATEGORY = "movies" ]]; then
  # matches: movie name (2013).xyz
  regex="(.*) \(([0-9]{4})\).*"

  mkIsofs
  consolidateFiles

  # find media file larger than 100MB
  file=$(find . -maxdepth 1 -type f -size +100000k -regextype "posix-extended" -iregex '.*\.(avi|divx|img|iso|m4v|mkv|mp4|ts|wmv)' ! -name atomicFile*.m4v)
echo $file
  # exit if no media files found
  if [[ ! -f "$file" ]]; then
    echo "!!! NO media file found"
    date
    exit 1
  fi

  echo "  - Discovered Media File:"
  NAME=$(echo ${file%.*} | sed -r 's/^\.\///g') # strip the leading "./" from the find results
  EXT=${file##*.}
  ISIZE=$(ls -lh "$file" | awk '{print $5}')
  echo "    $NAME.$EXT $ISIZE"
  # destination filename
  movie_dest_file="${file%.*}.m4v"

  if [[ $NAME =~ $regex ]]; then
    echo "  - REGEX detected Movie,"
    echo "  - $regex"
    echo

    # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
    year=${BASH_REMATCH[2]}
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
  findArtwork "$movie_artwork"
  encodeMovie
  tagMovie
  moveTranscoded "$movie_dest_file" "$movie_dest_folder"
  moveOriginal
  printMovieDetails
  echo "FINISH `date`"

fi

# END movies

# BEGIN tv

if [[ $CATEGORY = "tv" ]]; then
  # regex matches: show name - s01e02 - episode name.xyz
  regex="(.*) - S([0-9]{2})E([0-9]{2}) - (.*)$"

  # regex matches: the daily show - 2013-08-01 - episode name.xyz
  regex_dated="(.*)[- .]{3}([0-9]{4})[- .]([0-9]{2})[- .]([0-9]{2})[- .]{3}(.*).*"

  # custom processing for shows
  # regex matches: the soup - 2013-08-01 - episode name.xyz
  regex_soup="([tT][hH][eE] [sS][oO][uU][pP]) - ([0-9]{4})-([0-9]{2})-([0-9]{2}) - (.*)\..*"

  tvRenamer

  echo "  - Discovered media file:"
  COUNTER=0
  find . -maxdepth 1 -type f -size +30000k -regextype "posix-extended" -iregex '.*\.(avi|divx|img|iso|m4v|mkv|mp4|ts|wmv)'  ! -name atomicFile*.m4v -print0 | while IFS= read -r -d '' file; do
      let COUNTER=COUNTER+1
      echo "  - Loop Count = $COUNTER"
      NAME=$(echo ${file%.*} | sed -r 's/^\.\///g') # strip the leading "./" from the find results
      EXT=${file##*.}
      ISIZE=$(ls -lh "$file"  | awk '{print $5}')
      echo "    $NAME.$EXT $ISIZE"
  
    if [[ $NAME =~ $regex_soup ]]; then
      echo "  - REGEX detected The Soup,"
      echo "  - $regex_soup"
      echo "  - $file"
  
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      year=${BASH_REMATCH[2]}
      month=${BASH_REMATCH[3]}
      # strip leading 0 from month
      month=$(echo ${month} | sed -r 's/^0//g')
      day=${BASH_REMATCH[4]}
      # episode_name=${BASH_REMATCH[5]} # the soup doesn't have episode names
      season=$year
      episode=${month}${day}
      echo "  - \$show_name    = $show_name"
      echo "  - \$year         = $year"
      echo "  - \$month        = $month"
      echo "  - \$day          = $day"
      echo
  
      cleanupFilename "$show_name" x # function expects two variables
  
      # destination filename
      tv_dest_file="${show_name} - ${year}-${month}-${day}.m4v"
  
    elif [[ $CATEGORY = "tv" && $NAME =~ $regex_dated ]]; then
      echo "  - REGEX detected Dated TV Show,"
      echo "  - $regex_dated"
      echo "  - $file"
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      year=${BASH_REMATCH[2]}
      month=${BASH_REMATCH[3]}
      # strip leading 0 from month
      month=$(echo ${month} | sed -r 's/^0//g')
      day=${BASH_REMATCH[4]}
      episode_name=${BASH_REMATCH[5]}
      season=$year
      episode=${month}${day}
      echo "  - \$show_name    = $show_name"
      echo "  - \$year         = $year"
      echo "  - \$month        = $month"
      echo "  - \$day          = $day"
      echo "  - \$episode_name = $episode_name"
      echo
  
      cleanupFilename "$show_name" "$episode_name"
  
      # destination filename
      tv_dest_file="${show_name} - ${year}-${month}-${day} - ${episode_name}.m4v"
  
    elif [[ $CATEGORY = "tv" && $NAME =~ $regex ]]; then
      echo "  - REGEX detected TV Show,"
      echo "  - $regex"
      echo "  - $file"
      # the test operator '=~' against the $regex '(filter)' populates BASH_REMATCH array
      show_name=${BASH_REMATCH[1]}
      season=${BASH_REMATCH[2]}
      episode=${BASH_REMATCH[3]}
      episode_name=${BASH_REMATCH[4]}
      echo "  - \$show_name    = $show_name"
      echo "  - \$season       = $season"
      echo "  - \$episode      = $episode"
      echo "  - \$episode_name = $episode_name"
      echo
  
      cleanupFilename "$show_name" "$episode_name"
      
      # destination filename
      tv_dest_file="${show_name} - S${season}E${episode} - ${episode_name}.m4v"
  
    else
      echo "!!! REGEX error,"
      echo "!!! skipping $file"
      continue
    fi

    # TODO improve this
    # if there is already an M4V file stop
    if [[ -e "${tv_dest_folder}${tv_dest_file}" ]]; then
      echo "!!! An M4V with the same name already exists,"
      echo "!!! skipping $file"
      continue
    fi

    # when running via shell check for tag switch
    if [[ $8 != "tag" ]]; then
      encodeTv
    elif [[ $8 == "tag" ]]; then
      mv "${file}" "atomicFile.m4v"
      # sleep a bit
      sleep 3
    fi
    
    ls -l "atomicFile.m4v" > /dev/null 2>&1
    
    if [[ $? != 0 ]]; then
      echo "$file"
      echo "!!! ERROR, atomicFile.m4v missing"
      date
      exit 1
      continue
    fi

    tagTv "$show_name" "$episode_name" "$episode" "$season"
    moveTranscoded "$tv_dest_file" "$tv_dest_folder"
    moveOriginal
    printTvDetails
    echo "FINISH! `date`"

  done
# END tv
fi
