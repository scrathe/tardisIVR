# tardisIVR
A BASH post-processing script for Shell/SABnzbd/Radarr/Sonarr.

# Features
* Encode TV and Movies using HandBrake to meet your specific audio and video requirements.
* Passthru 2, 5.1, 7.1 audio channels.
* Tag mp4 metadata using AtomicParsley.
* Run from BASH shell to re-encode single files, or multiple directories.

# Requirements
* HandBrake https://github.com/HandBrake/HandBrake
```
add-apt-repository ppa:stebbins/handbrake-releases -y && apt-get update && apt-get install handbrake-cli -y
```
* MediaInfo https://github.com/MediaArea/MediaInfo
* lsof
* bc

## Optional
* AtomicParsley https://github.com/wez/atomicparsley
* tvNamer https://github.com/dbr/tvnamer
* mkisofs
* avimerge
* Encoding .iso requires sudoers nopasswd for mount/unmount commands

# Install
You can download the latest version clicking [here](https://github.com/scrathe/tardisIVR/archive/master.zip) or close the repository with the command below.
```
git clone https://github.com/scrathe/tardisIVR.git master
```

# Usage
### Sickbeard/CouchPotato/NZBDrobe
### Sonarr/Radarr
### Shell
#### If you're using a post-processing destination folder for pickup (SickBeard/CouchPotato)
```
ls
TV Show Name - S01E01 - Episode Name [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x tv
```
```
ls
Movie (2014) [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x movies
```
#### Or if you want to leave the newly encoded file in the source directory (Sonarr/Radarr)
```
ls
TV Show Name - S01E01 - Episode Name [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x sonarr
```
```
ls
Movie (2014) [HDTV].mkv
tardisIVRvideo.sh "`pwd`" x x x radarr
```
#### If you want to skip encoding and just tag mp4 metadata
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



# Examples

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
