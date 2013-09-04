# tardisIVR
### Internet Video Recorder w/ lots of space
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisIVR.png?raw=true "tardisIVR Blueprint")

## what is this?
* blueprints for box that holds Movies and TV shows
* in-a-nutshell...
  * a Windows host (front-end) for file management and sharing
  * a Linux guest (back-end) for download, rename, transcode, and tag (SABnzbd, SickBeard, CouchPotato, HeadPhones)
  * post-processing script (tardisIVRvideo.sh) encodes/handbrake & tags/tomicparsley for iTunes/AppleTV

## what you'll need
* a Windows host w/ Hypervisor (Win8/Hyper-V)
  * or two or more boxen.  hack freely!
* a Linux guest (ubuntu-12.04.2-server-amd64.iso)
  * 1-2GB RAM, 4-8GB HD, numerous-cpu-cores, bridged network
* working knowledge of SABnzbd, SickBeard, CouchPotato, HeadPhones (you know there are a ton of settings right?  this adds more settings... but! the end result is worth it.)
* usenet account, nzb index account, etc

### INSTALL.md
* Ubuntu 12.04 installation guide for SABnzbd/apt-get, SickBeard/git, CouchPotato/git, HeadPhones/git

### SETTINGS.md
* appendix for settings;  file paths, file naming conventions, tardis variables, SABnzbd, SickBeard, CouchPotato, HeadPhones, wheeeeeeee!
 
### PLINK.md
* installation and configuration guide for remote execution (plink.exe) from Windows -> Linux (this is where it gets strange, entirely optional.)
* tardisIVR.bat -- Windows script
* tardisIVR.sh -- Linux script

### HARDWARE.md
* an example mini-itx tardis build

### tardisIVRvideo.sh
* BASH script supports the following run scenarios;
  * via SABnzbd categories post-processing
  * locally via shell
  * recursive via shell -- i.e. process all Season subfolders
  * remotely via Windows/plink.exe
* uses/depends-on post-processing folder workflow in SABnzbd, SickBeard, and CouchPotato
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
**Movie tag only**
```
cd /media/Movies/Movie Name (2013)
~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "`pwd`" x x x movies x x tag
```
**TV recurse thru Season XX directories and tag**
```
cd /media/TV/Show Name
for i in * ; do cd "`pwd`" && ~/.sabnzbd/scripts/tardisIVR/tardisIVRvideo.sh "$i" x x x tv x x tag ; done
```
**!!! bugs**
* when using recursive, cleanup leftover files; cast.jpg, cast.jpg.1, .2, etc.  fixup -- ```
find -name cast.jpg* -exec rm {} \;```

### resources
* https://lefoxdufue.wordpress.com/2013/01/12/install-sabnzbd-sickbeard-transmission-on-ubuntu-12-04/
* http://www.visualnomads.com/2012/08/09/install-sabnzbd-sickbeard-and-couchpotato-on-ubuntu-12-04-lts/
* https://wiki.ubuntu.com/MountWindowsSharesPermanently
* http://www.samba.org/samba/docs/man/manpages-3/mount.cifs.8.html
* http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
* http://gskinner.com/RegExr/

