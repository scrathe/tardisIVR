# tardisIVR
### Internet Video Recorder w/ lots of space
![alt text](https://github.com/scrathe/tardisIVR/blob/master/files/tardisIVR.png?raw=true "tardisIVR Blueprint")

## what is this?
* blueprints for automated acquisition of Movies and TV shows for use with iTunes and AppleTV
* in-a-nutshell...
  * a Windows host (front-end) for file management and sharing
  * a Linux guest (back-end) for download, transcode, rename, and tag (SABnzbd, SickBeard, CouchPotato, HeadPhones)
  * post-processing script (tardisIVRvideo.sh) encodes and tags files for iTunes/AppleTV
* not perfect (alpha)
  * some code/conditions are untested.  look for "# untested" and "# improve this" comments.
  * HeadPhones is not working at this time

## what you'll need
* a Windows host w/ Hypervisor (Win8/Hyper-V)
* a Linux guest (ubuntu-12.04.2-server-amd64.iso)
  * 1-2GB RAM, 4-8GB HD, numerous-cores, bridged networking to your host's internet connection
* working knowledge of SABnzbd, SickBeard, CouchPotato, HeadPhones
* usenet account, nzb index account, etc

### INSTALL.md
* Ubuntu 12.04 installation guide for SABnzbd, SickBeard, CouchPotato, HeadPhones

### SETTINGS.md
* settings guide for;  file paths, file naming conventions, tardis scripts, SABnzbd, SickBeard, CouchPotato, HeadPhones
 
### PLINK.md
* installation and configuration guide for remote execution (plink.exe) from Windows -> Linux
* tardisIVR.bat -- Windows script
* tardisIVR.sh -- Linux script

### HARDWARE.md
* an example mini-itx tardis build

### tardisIVRvideo.sh
* BASH script supporting the following run scenarios;
  * via SABnzbd categories post-processing
  * locally via shell
  * recursive via shell -- i.e. process all Season subfolders
  * remotely via Windows/plink.exe
* uses post-processing folder workflow in SABnzbd, SickBeard, and CouchPotato
* tags Movies with Title, Year, Artwork
* tags TV shows with Title, Season, Episode, Episode Name, Artwork
  * regex supporting traditional "S01E01" and dated "2013-08-01" TV show naming formats
* improved SABnzbd rename stripping; PROPER, 1080p, 720p, etc

### example tardisIVRvideo.sh usage
*standard SABnzbd post-processing arguments*
```
$1=DIR="/media/tardis-x/media/Movies/Movie (2013)/"
$2=NZB_FILE="Movie (2013).nzb"
$3=NAME="Movie (2013)"
$4=NZB_ID=""
$5=CATEGORY="movies"
$6=GROUP="alt.binaries.teevee"
$7=STATUS="0"
```
*additional tardisIVRvideo.sh arguments*
```
$8=tag   # "tag" using AtomicParsley rather than full HandBrake re-encode processing
```
##### example shell usage
**TV encode and tag**
```
$1=DIR, $5=CATEGORY
```
```
cd /media/TV/Show Name
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x tv x x
```
**TV tag**
```
$1=DIR, $5=CATEGORY, and/or $8 if "tag" only -- no re-encode
```
```
cd /media/TV/Show Name
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x tv x x tag
```
**Movie**
```
cd /media/Movies/Movie Name (2013)
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x movies x x tag
```
**TV recurse thru Season directories and tag**
```
cd /media/TV/Show Name
for i in * ; do cd "`pwd`" && ~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "$i" x x x tv x x tag ; done
```
**!!! bugs**
* when using recursive, cleanup leftover files; cast.jpg, cast.jpg.1, .2, etc.  fixup -- 
```
find -name cast.jpg* -exec rm {} \;
```
