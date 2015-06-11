### This guide is specific to a Win8 host with an Ubuntu 12.04 Hyper-V guest```‎(/.__.)/ \(.__.\)```

### Windows Host (Win8.x Pro/Ultimate w/ Hyper-V)
* share your storage... \\\servername\sharename
* setup your Linux guest;  1-2GB RAM, 8-12GB HD, numerous-cores, bridged networking to your host's internet connection
 
### Linux Guest (ubuntu-12.04.2-server-amd64.iso)
* Ubuntu 12.04 installation guide for SABnzbd, SickBeard, CouchPotato, HeadPhones

##### first things first, create/use a sudo enabled user e.g. elvie
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
you won't be using sudo when installing. we wants these apps to run-as non-root.
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

##### smb credentials file
```
vi ~/.smbcredentials
username=elvie
password=********
domain=tardis
```

##### secure smb credentials file
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

### tvrenamer.pl install
```
cd ~
wget https://github.com/meermanr/TVSeriesRenamer/raw/master/tvrenamer.pl
sudo mv tvrenamer.pl /usr/local/bin/
sudo chmod +x /usr/local/bin/tvrenamer.pl
sudo apt-get install -y libterm-readkey-perl libwww-perl
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
