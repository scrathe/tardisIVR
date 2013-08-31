# tardisIVR

## what is it?
* blueprints for automated acquisition of Movies and TV shows for use with iTunes and AppleTV.
* in-a-nutshell a Windows host (front-end) is for file management and iTunes.  while the back-end Linux guest is for download, transcode, rename, and tag.
  * a Win8.x host serving a Linux guest running; SABnzbd, SickBeard, CouchPotato, HeadPhones
  * custom post-processing script that uses HandBrake and AtomicParsley to encode iTunes/AppleTV specific files.

## features?
* post-processing script (tardisIVRvideo.sh) supports several run scenarios;
  * vai SABnzbd/categories
  * locally via shell
  * recursive via shell -- i.e. process all Season subfolders
  * remotely via plink.exe
* manages traditional "S01E01" and dated "2013-08-01" TV show naming formats
