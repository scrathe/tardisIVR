# tardisIVR
A BASH post-processing script for Shell/SABnzbd/Radarr/Sonarr.

### Features
* Encode TV and Movies using HandBrake to meet your specific audio and video requirements.
* Passthru 2, 5.1, 7.1 audio channels.
* Tag mp4 metadata using AtomicParsley.
* Run from BASH shell to re-encode single files, or multiple directories.

### Example
```
/movies/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x movies x x 
START! Fri Jan 26 03:23:24 UTC 2018
  - Consolidating files in /movies/Movies/Movie Name (2016)

  - Discovered Media File:
    Movie Name (2016).mkv 6.8G
  - REGEX detected Movie,
  - (.*) \(([0-9]{4})\)[- .]{0,3}(\[.*\])?.*

  - Audio Channels:  6
  * Transcoding!!!
/usr/bin/HandBrakeCLI -i "Movie Name (2016).mkv" -o atomicFile.m4v -e x264 -q 20 --optimize --srt-lang eng --native-language eng --native-dub -f mp4 --decomb --loose-anamorphic --modulus 2 -m --x264-preset medium --h264-profile high --h264-level 4.1 --aencoder ca_aac,copy:ac3,copy:dts,copy:dtshd

  - Encoding Speed: 123.86 minutes
  - Details:
    DIR:             /movies/Movies/Movie Name (2016)
    NZB_FILE:        x
    NAME:            Movie Name (2016)
    NZB_ID:          x
    CATEGORY:        movies
    GROUP:           x
    STATUS:          x
    Dest Folder:     /movies/postprocessing/movies/
    Dest File:       Movie Name (2016).m4v
    Title:           Movie Name (2016)
    Year:            2016
    Audio Channels:  6
    Quality:         
    Input File:      Movie Name (2016).mkv 6.8G
  - Finished:        Fri Jan 26 05:27:22 UTC 2018

  * MOVIE COMPLETE!  Movie Name (2016).m4v 
  * Moving transcoded file to folder.
  - mv atomicFile.m4v "/movies/postprocessing/movies/Movie Name (2016).m4v"
  * Moving original downloaded file to folder.
Fri Jan 26 05:27:22 UTC 2018
```
---
### Requirements
* HandBrake https://github.com/HandBrake/HandBrake
```
add-apt-repository ppa:stebbins/handbrake-releases -y && apt-get update && apt-get install handbrake-cli -y
```
* MediaInfo https://github.com/MediaArea/MediaInfo
* lsof
* bc

### Optional
* AtomicParsley https://github.com/wez/atomicparsley
* tvNamer https://github.com/dbr/tvnamer
* mkisofs
* avimerge
* Encoding .iso requires sudoers nopasswd for mount/unmount commands

### Install
You can download the latest version clicking [here](https://github.com/scrathe/tardisIVR/archive/master.zip) or close the repository with the command below.
```
git clone https://github.com/scrathe/tardisIVR.git master
```
---
### Shell Usage
#### TV
```
ls
TV Show Name - S01E01 - Episode Name [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x tv
```
#### Movies
```
ls
Movie (2014) [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x movies
```
#### Tag only, don't encode.
```
ls
TV Show Name - S01E01 - Episode Name [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x tv x x tag
```
```
ls
Movie (2014) [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x movies x x tag
```
---
### Examples
```
# movie encode and tag
cd /media/Movies/Movie Name (2013)
/tv/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x movies x x
```
```
# movie tag, skip encoding
cd /media/TV/Show Name (2013)
/tv/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x tv x x tag
```
```
# recurse through thru seasons of a TV show and encode
cd /media/TV/Show Name
for i in * ; do cd "`pwd`" && /tv/scripts/tardisIVR/tardisIVRvideo.sh "$i" x x x tv; done
```
```
# in a download directory full of TV shows in directories, find a show by name and encode all of those.
for i in `ls -d ShowName*` ; do cd "$i" && /tv/scripts/tardisIVR/tardisIVRvideo.sh `pwd` x x x tv x x ; cd .. ; done
```
---
### SABnzbd with SickBeard
```
Category = tv
Script = tardisIVRvideo.sh
Folder = tv
```

### SABnzbd with CouchPotato
```
Category = movies
Script = tardisIVRvideo.sh
Folder = movies
```

![SABnzbd](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisIVR-Sonarr1.png?raw=true)

### Sonarr
```
Arguments = x x x x sonarr
```

### Radarr
```
Arguments = x x x x radarr
```

![Sonarr](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisIVR-Sonarr2.png?raw=true)
---
#### Sources
Thank You!
* https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
* https://lefoxdufue.wordpress.com/2013/01/12/install-sabnzbd-sickbeard-transmission-on-ubuntu-12-04/
* http://www.visualnomads.com/2012/08/09/install-sabnzbd-sickbeard-and-couchpotato-on-ubuntu-12-04-lts/
* https://wiki.ubuntu.com/MountWindowsSharesPermanently
* http://www.samba.org/samba/docs/man/manpages-3/mount.cifs.8.html
* http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
* http://gskinner.com/RegExr/
* http://www.mindtwist.de/main/linux/3-linux-tipps/9-how-to-mass-convert-dvd-folders-to-iso-files.html
* https://gist.github.com/donmelton/5734177
