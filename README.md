# tardisIVR

![alt text](https://github.com/scrathe/tardisIVR/blob/master/tardisIVR.png?raw=true "tardisIVR Blueprint")

## what is it?
* blueprints for automated acquisition of Movies and TV shows for use with iTunes and AppleTV.
* in-a-nutshell a Windows host (front-end) for file management and sharing.  a Linux guest (back-end) for download, transcode, rename, and tag.
  * a Win8.x host serving a Linux guest running; SABnzbd, SickBeard, CouchPotato, HeadPhones
  * custom post-processing script using HandBrake and AtomicParsley to encode and tag files for iTunes/AppleTV.

## FILES
### INSTALL.md
* installation guide for SABnzbd, SickBeard, CouchPotato, HeadPhones

### CONFIG.md
* configuration guide
 
### tardisIVRvideo.sh
* BASH script supporting the following run scenarios;
  * via SABnzbd categories post-processing
  * locally via shell
  * recursive via shell -- i.e. process all Season subfolders
  * remotely via windows/plink.exe
* uses post-processing folder workflow in SABnzbd, SickBeard, and CouchPotato
* tags Movies with Title, Year, Artwork
* tags TV shows with Title, Season, Episode, Episode Name, Artwork
  * regex supporting traditional "S01E01" and dated "2013-08-01" TV show naming formats
* improved SABnzbd rename stripping; PROPER, 1080p, 720p, etc

### PLINK.md
* installation and configuration guide for FileMenuTools -- remotely execute tardisIVRvideo.sh from Windows using plink.exe
