### This guide is specific to a```‎(/.__.)/```Win8 host with an Ubuntu 12.04```\(.__.\)```Hyper-V guest

### Windows front-end (Win8.x Pro/Ultimate w/ Hyper-V)
* share your storage... \\\servername\sharename
* setup your Linux guest;  1-2GB RAM, 8-12GB HD, numerous-cores, bridged networking to your host's internet connection
 
### Linux back-end (ubuntu-12.04.2-server-amd64.iso)
* Ubuntu 12.04 installation guide for SABnzbd, SickBeard, CouchPotato, HeadPhones

##### first things first, on your Linux back-end, create/use a sudo enabled user e.g. elvie
```
sudo usermod -a -G sudo elvie
```
##### check group membership (you may need to logout/in for new group membership)
```
sudo groups elvie
```

##### install some prereqs
```
sudo apt-get install -y avimerge genisoimage git openssh-server wget
```

##### download tardisIVRvideo.sh to SABnzbd's script directory
note: you won't be using sudo when installing. we wants these apps to run-as non-root.
```
git clone https://github.com/scrathe/tardisIVR.git ~/.sabnzbd/scripts/tardisIVR
```

##### mount windows shares
* bug?  can not mount \\\server\c$ administrative share.  i suspect this is a new Win8 security default.
* Windows share: \\\servername\sharename
* Linux mount:   /media/sharename

```
sudo apt-get install -y smbfs
sudo vi /etc/fstab
//tardis/c /media/tardis-c cifs noauto,rw,uid=elvie,credentials=/home/elvie/.smbcredentials,iocharset=utf8,file_mode=0770,dir_mode=0770,sec=ntlm 0 0
```

##### create and secure the .smbcredentials file
```
vi ~/.smbcredentials
username=elvie
password=********
domain=tardis
```
```
chmod 600 ~/.smbcredentials
```
##### /etc/fstab "noauto" setting
* use /etc/rc.local to delay mounting volumes until network is up

```
sudo vi /etc/rc.local
mount /media/tardis-c
mount /media/tardis-x
end
```

##### mount
```
sudo mount /media/tardis-c
sudo mount /media/tardis-x
sudo df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       7.9G  2.5G  5.1G  33% /
udev            2.0G  4.0K  2.0G   1% /dev
tmpfs           790M  244K  790M   1% /run
none            5.0M     0  5.0M   0% /run/lock
none            2.0G     0  2.0G   0% /run/shm
//tardis/c      239G   70G  169G  30% /media/tardis-c
//tardis/x      7.3T  5.6T  1.8T  76% /media/tardis-x
```

### handbrake install
```
sudo apt-get install ubuntu-restricted-extras
sudo apt-get install libdvdread4
sudo /usr/share/doc/libdvdread4/install-css.sh
sudo apt-get install python-software-properties apt-file
sudo add-apt-repository ppa:stebbins/handbrake-snapshots
sudo apt-get update
sudo apt-get install handbrake-cli
sudo ln -s /usr/bin/HandBrakeCLI /usr/bin/handbrake-cli
```

### atomicparsley install
```
sudo apt-get install -y atomicparsley
sudo ln -s /usr/bin/AtomicParsley /usr/bin/atomicparsley
```

### tvnamer install; https://github.com/dbr/tvnamer
```
sudo apt-get install python-setuptools
sudo easy_install tvnamer
```

#### tvnamer config
```
vi ~/.tvnamer.json
```
```
{
    "always_rename": false, 
    "batch": true, 
    "custom_filename_character_blacklist": "", 
    "episode_separator": "-", 
    "episode_single": "%d", 
    "filename_patterns": [
        "^\\[.+?\\][ ]? # group name\n        (?P<seriesname>.*?)[ ]?[-_][ ]?          # show name, padding, spaces?\n        (?P<episodenumberstart>\\d+)              # first episode number\n        ([-_]\\d+)*                               # optional repeating episodes\n        [-_](?P<episodenumberend>\\d+)            # last episode number\n        [^\\/]*$", 
        "^\\[.+?\\][ ]? # group name\n        (?P<seriesname>.*) # show name\n        [ ]?[-_][ ]?(?P<episodenumber>\\d+)\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        [Ss](?P<seasonnumber>[0-9]+)             # s01\n        [\\.\\- ]?                                 # separator\n        [Ee](?P<episodenumberstart>[0-9]+)       # first e23\n        ([\\.\\- ]+                                # separator\n        [Ss](?P=seasonnumber)                    # s01\n        [\\.\\- ]?                                 # separator\n        [Ee][0-9]+)*                             # e24 etc (middle groups)\n        ([\\.\\- ]+                                # separator\n        [Ss](?P=seasonnumber)                    # last s01\n        [\\.\\- ]?                                 # separator\n        [Ee](?P<episodenumberend>[0-9]+))        # final episode number\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        [Ss](?P<seasonnumber>[0-9]+)             # s01\n        [\\.\\- ]?                                 # separator\n        [Ee](?P<episodenumberstart>[0-9]+)       # first e23\n        ([\\.\\- ]?                                # separator\n        [Ee][0-9]+)*                             # e24e25 etc\n        [\\.\\- ]?[Ee](?P<episodenumberend>[0-9]+) # final episode num\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        (?P<seasonnumber>[0-9]+)                 # first season number (1)\n        [xX](?P<episodenumberstart>[0-9]+)       # first episode (x23)\n        ([ \\._\\-]+                               # separator\n        (?P=seasonnumber)                        # more season numbers (1)\n        [xX][0-9]+)*                             # more episode numbers (x24)\n        ([ \\._\\-]+                               # separator\n        (?P=seasonnumber)                        # last season number (1)\n        [xX](?P<episodenumberend>[0-9]+))        # last episode number (x25)\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        (?P<seasonnumber>[0-9]+)                 # 1\n        [xX](?P<episodenumberstart>[0-9]+)       # first x23\n        ([xX][0-9]+)*                            # x24x25 etc\n        [xX](?P<episodenumberend>[0-9]+)         # final episode num\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        [Ss](?P<seasonnumber>[0-9]+)             # s01\n        [\\.\\- ]?                                 # separator\n        [Ee](?P<episodenumberstart>[0-9]+)       # first e23\n        (                                        # -24 etc\n             [\\-]\n             [Ee]?[0-9]+\n        )*\n             [\\-]                                # separator\n             [Ee]?(?P<episodenumberend>[0-9]+)   # final episode num\n        [\\.\\- ]                                  # must have a separator (prevents s01e01-720p from being 720 episodes)\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        (?P<seasonnumber>[0-9]+)                 # 1\n        [xX](?P<episodenumberstart>[0-9]+)       # first x23\n        (                                        # -24 etc\n             [\\-][0-9]+\n        )*\n             [\\-]                                # separator\n             (?P<episodenumberend>[0-9]+)        # final episode num\n        ([\\.\\- ].*                               # must have a separator (prevents 1x01-720p from being 720 episodes)\n        |\n        $)", 
        "^(?P<seriesname>.+?)[ \\._\\-]          # show name and padding\n        \\[                                       # [\n            ?(?P<seasonnumber>[0-9]+)            # season\n        [xX]                                     # x\n            (?P<episodenumberstart>[0-9]+)       # episode\n            (- [0-9]+)*\n        -                                        # -\n            (?P<episodenumberend>[0-9]+)         # episode\n        \\]                                       # \\]\n        [^\\/]*$", 
        "^(?P<seriesname>.+?)[ \\._\\-]\n        [Ss](?P<seasonnumber>[0-9]{2})\n        [\\.\\- ]?\n        (?P<episodenumber>[0-9]{2})\n        [^0-9]*$", 
        "^((?P<seriesname>.+?)[ \\._\\-])?       # show name and padding\n        \\[?                                      # [ optional\n        (?P<seasonnumber>[0-9]+)                 # season\n        [xX]                                     # x\n        (?P<episodenumber>[0-9]+)                # episode\n        \\]?                                      # ] optional\n        [^\\/]*$", 
        "^((?P<seriesname>.+?)[ \\._\\-])?\n        \\[?\n        [Ss](?P<seasonnumber>[0-9]+)[\\.\\- ]?\n        [Ee]?(?P<episodenumber>[0-9]+)\n        \\]?\n        [^\\/]*$", 
        "\n        ^((?P<seriesname>.+?)[ \\._\\-])?          # show name\n        (?P<year>\\d{4})                          # year\n        [ \\._\\-]                                 # separator\n        (?P<month>\\d{2})                         # month\n        [ \\._\\-]                                 # separator\n        (?P<day>\\d{2})                           # day\n        [^\\/]*$", 
        "^(?P<seriesname>.+?)[ ]?[ \\._\\-][ ]?\n        [Ss](?P<seasonnumber>[0-9]+)[\\.\\- ]?\n        [Ee]?[ ]?(?P<episodenumber>[0-9]+)\n        [^\\/]*$", 
        "\n        (?P<seriesname>.+)                       # Showname\n        [ ]-[ ]                                  # -\n        [Ee]pisode[ ]\\d+                         # Episode 1234 (ignored)\n        [ ]\n        \\[                                       # [\n        [sS][ ]?(?P<seasonnumber>\\d+)            # s 12\n        ([ ]|[ ]-[ ]|-)                          # space, or -\n        ([eE]|[eE]p)[ ]?(?P<episodenumber>\\d+)   # e or ep 12\n        \\]                                       # ]\n        .*$                                      # rest of file\n        ", 
        "^(?P<seriesname>.+?)                  # Show name\n        [ \\._\\-]                                 # Padding\n        (?P<episodenumber>[0-9]+)                # 2\n        of                                       # of\n        [ \\._\\-]?                                # Padding\n        \\d+                                      # 6\n        ([\\._ -]|$|[^\\/]*$)                     # More padding, then anything\n        ", 
        "^(?P<seriesname>.+)[ \\._\\-]\n        (?P<seasonnumber>[0-9]{1})\n        (?P<episodenumber>[0-9]{2})\n        [\\._ -][^\\/]*$", 
        "^(?P<seriesname>.+)[ \\._\\-]\n        (?P<seasonnumber>[0-9]{2})\n        (?P<episodenumber>[0-9]{2,3})\n        [\\._ -][^\\/]*$", 
        "^(?P<seriesname>.+?)                  # Show name\n        [ \\._\\-]                                 # Padding\n        [Ee](?P<episodenumber>[0-9]+)            # E123\n        [\\._ -][^\\/]*$                          # More padding, then anything\n        "
    ], 
    "filename_with_date_and_episode": "%(seriesname)s - %(episode)s - %(episodename)s%(ext)s", 
    "filename_with_date_without_episode": "%(seriesname)s - %(episode)s%(ext)s", 
    "filename_with_episode": "%(seriesname)s - %(seasonno)dx%(episode)s - %(episodename)s%(ext)s", 
    "filename_with_episode_no_season": "%(seriesname)s - %(episode)s - %(episodename)s%(ext)s", 
    "filename_without_episode": "%(seriesname)s - %(seasonno)dx%(episode)s%(ext)s", 
    "filename_without_episode_no_season": "%(seriesname)s - %(episode)s%(ext)s", 
    "input_filename_replacements": [], 
    "language": "en", 
    "lowercase_filename": false, 
    "move_files_confirmation": true, 
    "move_files_destination": ".", 
    "move_files_enable": false, 
    "move_files_fullpath_replacements": [], 
    "multiep_join_name_with": ", ", 
    "normalize_unicode_filenames": false, 
    "output_filename_replacements": [], 
    "recursive": false, 
    "replace_invalid_characters_with": "_", 
    "search_all_languages": true, 
    "select_first": false, 
    "skip_file_on_error": true, 
    "valid_extensions": [], 
    "verbose": false, 
    "windows_safe_filenames": false
}
```

### sabnzbd:8080 install
```
echo "deb http://ppa.launchpad.net/jcfp/ppa/ubuntu $(lsb_release -c -s) main" | sudo tee -a /etc/apt/sources.list && sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F
sudo apt-get update
sudo apt-get install sabnzbdplus
sudo vi /etc/default/sabnzbdplus
sudo update-rc.d sabnzbdplus defaults
```

### sickbeard:8081 install
```
cd ~
git clone https://github.com/midgetspy/Sick-Beard.git .sickbeard
sudo cp .sickbeard/init.ubuntu /etc/init.d/sickbeard
sudo vi /etc/init.d/sickbeard
sudo chmod +x /etc/init.d/sickbeard
sudo update-rc.d sickbeard defaults
```

##### change defaults
```
sudo vi /etc/default/sickbeard
#!/bin/bash
## SB_USER=         #$RUN_AS, username to run sickbeard under, the default is sickbeard
## SB_HOME=         #$APP_PATH, the location of SickBeard.py, the default is /opt/sickbeard
## SB_DATA=         #$DATA_DIR, the location of sickbeard.db, cache, logs, the default is /opt/sickbeard
## SB_PIDFILE=      #$PID_FILE, the location of sickbeard.pid, the default is /var/run/sickbeard/sickbeard.pid
## PYTHON_BIN=      #$DAEMON, the location of the python binary, the default is /usr/bin/python
## SB_OPTS=         #$EXTRA_DAEMON_OPTS, extra cli option for sickbeard, i.e. " --config=/home/sickbeard/config.ini"
## SSD_OPTS=        #$EXTRA_SSD_OPTS, extra start-stop-daemon option like " --group=users"
SB_USER="elvie"
SB_HOME="/home/$SB_USER/.sickbeard"
SB_DATA="/home/$SB_USER/.sickbeard"
SB_PORT="8081"
```

### couchpotato:5050 install
* note:  do not use ~/.couchpotato.  app reserves this folder for your settings.

```
cd ~
git clone https://github.com/RuudBurger/CouchPotatoServer.git .couchpotato_v2
sudo cp .couchpotato_v2/init/ubuntu /etc/init.d/couchpotato
sudo cp .couchpotato_v2/init/ubuntu.default /etc/default/couchpotato
sudo chmod +x /etc/init.d/couchpotato
sudo update-rc.d couchpotato defaults
```

##### change defaults
```
sudo vi /etc/default/couchpotato
# COPY THIS FILE TO /etc/default/couchpotato
# OPTIONS: APP_PATH, RUN_AS, DAEMON_PATH, CP_PID_FILE
RUN_AS=elvie
APP_PATH=/home/$RUN_AS/.couchpotato_v2
```
* bug:  may need to restart couchpotato a few times after initial run

### headphones:8084 install
```
cd ~
git clone https://github.com/rembo10/headphones.git .headphones
sudo cp .headphones/init.ubuntu /etc/init.d/headphones
sudo chmod +x /etc/init.d/headphones
sudo update-rc.d headphones defaults
```

##### change defaults
```
sudo vi /etc/default/headphones
#!/bin/bash
## HP_USER=         #$RUN_AS, username to run headphones under, the default is headphones
## HP_HOME=         #$APP_PATH, the location of Headphones.py, the default is /opt/headphones
## HP_DATA=         #$DATA_DIR, the location of headphones.db, cache, logs, the default is /opt/headphones
## HP_PIDFILE=      #$PID_FILE, the location of headphones.pid, the default is /var/run/headphones/headphones.pid
## PYTHON_BIN=      #$DAEMON, the location of the python binary, the default is /usr/bin/python
## HP_OPTS=         #$EXTRA_DAEMON_OPTS, extra cli option for headphones, i.e. " --config=/home/headphones/config.ini"
## SSD_OPTS=        #$EXTRA_SSD_OPTS, extra start-stop-daemon option like " --group=users"
## HP_PORT=         #$PORT_OPTS, hardcoded port for the webserver, overrides value in config.ini
HP_USER="elvie"
HP_HOME="/home/$HP_USER/.headphones"
HP_DATA="/home/$HP_USER/.headphones"
HP_PORT="8084"
```
