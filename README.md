# tardisIVR
### a box that's bigger on the inside to put the internet in.
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisIVR.png?raw=true "tardisIVR Blueprint")

## what is this?
* blueprints for a box that holds Movies and TV shows
  * a Windows host (front-end) for file management and sharing
  * a Linux guest (back-end) for download, rename, transcode, and tag (SABnzbd, SickBeard, CouchPotato, HeadPhones)
  * a BASH post-processing script (tardisIVRvideo.sh) that encodes and tags for iTunes/AppleTV using HandBrake and AtomicParsley

## what does it require?
* a Windows 8 machine with plenty of redundant storage
  * Q: ewwww, do i have to use Win8?  A: absolutely not -- use any Hypervisor or bare-metal.
* a Linux virtual machine
  * ubuntu-12.04.3-server-amd64.iso, RAM 1-2GB, HD 4-8GB, CPU 2+ cores, Bridged networking
* a strong understanding of SABnzbd, SickBeard, CouchPotato, HeadPhones (you know there are a ton of settings right?  this adds more settings...)
* a usenet account and nzb index account

## files
**HARDWARE.md**
  * an example mini-itx tardis build (the files are inside? the computer?)

**INSTALL.md**
  * Ubuntu 12.04 installation guide for SABnzbd/apt-get, SickBeard/git, CouchPotato/git, HeadPhones/git

**PLINK.md**
  * optional installation and configuration guide for remote execution (plink.exe) from Windows -> Linux
  * **plink-tardisIVR.bat** -- Windows script
  * **plink-tardisIVR.sh** -- Linux script

**SETTINGS.md**
  * appendix for settings; SABnzbd, SickBeard, CouchPotato, HeadPhones, file paths, file naming, script variables
 
**tardisIVRvideo.sh**
  * BASH script supports run scenarios:
    * via SABnzbd categories post-processing
    * locally via shell
    * recursive via shell -- i.e. process all Season subfolders
    * remotely via Windows/plink.exe
  * uses/depends-on post-processing folder workflow in SABnzbd, SickBeard, and CouchPotato
  * supports TV SeasonEpisode (S01E01) and Dated (2013-08-01) filenames
  * attempts to improve SABnzbd filename stripping (PROPER, 1080p, 720p)

## example tardisIVRvideo.sh usage
*standard SABnzbd post-processing arguments*
```
$1=DIR="/media/tardis-x/media/Movies/Movie (2013)/"
$2=NZB_FILE="Movie (2013).nzb"
$3=NAME="Movie (2013)"
$4=NZB_ID=""
$5=CATEGORY="movies"
$6=GROUP="alt.binaries.tardis"
$7=STATUS="0"
```
*additional tardisIVRvideo.sh arguments*
```
$8=tag   # just "tag" with AtomicParsley rather than the full HandBrake re-encode then tag process
```
## example shell usage
**TV encode and tag**
```
$1=DIR, $5=CATEGORY
```
```
cd /media/TV/Show Name/Season 01
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x tv x x
```
**TV tag only**
```
$1=DIR, $5=CATEGORY, and/or $8 if "tag" only -- no re-encode
```
```
cd /media/TV/Show Name/Season 01
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x tv x x tag
```
**Movie encode and tag**
```
cd /media/Movies/Movie Name (2013)
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x movies x x
```
**TV recurse thru Season XX directories and tag**
```
cd /media/TV/Show Name
for i in * ; do cd "`pwd`" && ~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "$i" x x x tv x x tag ; done
```

## sources
* https://lefoxdufue.wordpress.com/2013/01/12/install-sabnzbd-sickbeard-transmission-on-ubuntu-12-04/
* http://www.visualnomads.com/2012/08/09/install-sabnzbd-sickbeard-and-couchpotato-on-ubuntu-12-04-lts/
* https://wiki.ubuntu.com/MountWindowsSharesPermanently
* http://www.samba.org/samba/docs/man/manpages-3/mount.cifs.8.html
* http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
* http://gskinner.com/RegExr/
* http://www.mindtwist.de/main/linux/3-linux-tipps/49-how-to-mass-rename-your-iso-movie-database.html
