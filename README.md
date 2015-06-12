# tardisIVR
### A box that's bigger on the inside to put the internet in.
![alt text](https://www.gliffy.com/go/publish/image/8327655/L.png "tardisIVR Blueprint")

## What is this?
* Blueprints for a system that automates the download, encoding, naming and metadata tagging of Movies and TV shows. comprised of:
  * Baremetal host (front-end) for file management and sharing
  * Linux VM or baremetal (back-end) for search and download (SickBeard, CouchPotato, HeadPhones, SABnzbd)
  * BASH post-processing script (tardisIVRvideo.sh) that renames, encodes and tags (tvnamer, HandBrake, AtomicParsley) compatibile with media sharing environments; iTunes/AppleTV, Plex, DLNA, FireTV, Roku, anything!

## What does it require?
* Baremetal host with plenty of redundant storage
  * e.g. Win8.x Pro w/ Hyper-V, Linux w/ Proxmox, Apple w/ Virtualbox
* Linux virtual guest or standalone baremetal machine
  * e.g. ubuntu-12.04.3-server-amd64.iso, RAM 1-2GB, HD 8-12GB, CPU 2+ cores, Bridged networking
* Strong understanding of SABnzbd, SickBeard, CouchPotato, HeadPhones (you know there are a ton of settings right?  this adds more settings...)
* Usenet and nzb index account
* Patience and/or love of a challenge```(づ｡◕‿‿◕｡)づ```

### Files
#### tardisIVRvideo.sh
  * BASH script supports run scenarios:
    * via SABnzbd categories post-processing
    * locally via shell
    * recursive via shell -- i.e. process all Season subfolders
    * remotely via Windows/plink.exe
    * see the [Wiki](https://github.com/scrathe/tardisIVR/wiki/Shell-Usage) for examples.
  * Uses/depends-on post-processing folder workflow in SABnzbd, SickBeard, and CouchPotato
  * Supports TV SeasonEpisode (S01E01) and Dated (2013-08-01) filenames
  * Attempts to improve SABnzbd filename stripping (PROPER, 1080p, 720p)

#### plink-tardisIVR
  * See the [Wiki](https://github.com/scrathe/tardisIVR/wiki/Plink-(Remote-Execution)) for installation and configuration of the remote execution.
  (plink.exe) from Windows -> Linux
  * **plink-tardisIVR.bat** -- Windows script
  * **plink-tardisIVR.sh** -- Linux script

## Sources
thank you!
* https://forums.sabnzbd.org/viewtopic.php?p=30111&sid=a21a927758babb5b77386faa31e74f85#p30111
* https://lefoxdufue.wordpress.com/2013/01/12/install-sabnzbd-sickbeard-transmission-on-ubuntu-12-04/
* http://www.visualnomads.com/2012/08/09/install-sabnzbd-sickbeard-and-couchpotato-on-ubuntu-12-04-lts/
* https://wiki.ubuntu.com/MountWindowsSharesPermanently
* http://www.samba.org/samba/docs/man/manpages-3/mount.cifs.8.html
* http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
* http://gskinner.com/RegExr/
* http://www.mindtwist.de/main/linux/3-linux-tipps/9-how-to-mass-convert-dvd-folders-to-iso-files.html
