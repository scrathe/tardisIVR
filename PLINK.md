## right-click remote execution Windows/host -> Linux/guest
* **how** -- use plink.exe to send remote execution
* **problem** -- ```C:\Windows\directory\structure != /Linux/directory/structure```
  * from Windows -- ```X:\media\TV\Show Name\Season 01```
  * to Linux -- ```/media/tardis-x/media/TV/Show Name/Season 01```
* **solution** -- use FileMenuTools on Windows host, Windows Explorer right-click command (plink-tardisIVR.bat) sends a $variable with the current Windows directory you right-clicked in.  bash script (plink-tardisIVR.sh) on Linux guest converts parent directory naming and slashes before passing command to post-processing script (tardisIVRvideo.sh).
* **improve this** -- since we're reusing the tardisIVRvideo.sh script and SABnzbd arguments (x x x category x x tag), it moves the processed file back into postprocessing directories (SickBeard, CouchPotato).  works as-is, but could be improved with additional case arguments.

#### guest
* modify ```plink-tardisIVR.sh```
* modify ```$win_path``` and ```$lnx_path``` variables.  remember to use triple-slash '\\\\\\' for windows directories.

```
vi ~/.sabnzbd/scripts/tardisIVR/plink-tardisIVR.sh
```

#### host
* modify ```plink-tardisIVR.bat```
* add plink.exe to windows $PATH
* create SSH key (.ppk) and test authentication

```
plink -batch -i c:\path\to\key.ppk user@linux "ls"
```

* install FileMenuTools;  http://www.lopesoft.com/en/filemenutools
* provides custom right-click menu
* configure FileMenuTools.  uncheck all the unneeded commands.
* add (4) commands and modify properties to match settings and arguments below
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/fileMenuTools01.png?raw=true "FileMenuTools Setup")

