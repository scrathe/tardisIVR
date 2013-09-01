REM FileMenuTools
REM Arguments = tv
REM Arguments = tv tag
REM Arguments = movies
REM Arguments = movies tag

plink -batch -i X:\Profile\Documents\keys\ssh-tardis.ppk elvie@tardis "/home/elvie/.sabnzbd/scripts/plink-tardisIVR.sh \"%CD%\"" %1 %2
PAUSE
