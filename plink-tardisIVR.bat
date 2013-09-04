REM arguments are passed in from FileMenuTools
REM example usage:
REM arguments = tv
REM arguments = tv tag
REM arguments = movies
REM arguments = movies tag

REM %CD% = current director $CD as argument to plink-tardisIVR.sh
REM %1   = "tv" or "movies"
REM %2   = <blank> = encode/handbrake and tag/atomicparsley
REM       or "tag" = tag/atomicparsley

REM add plink.exe to windows $PATH

plink -batch -i X:\Profile\Documents\keys\ssh-tardis.ppk elvie@tardis "~/.sabnzbd/scripts/tardisIVR/plink-tardisIVR.sh \"%CD%\"" %1 %2
PAUSE
