#!/usr/bin/env bash

### [C.U.M. UPDATE WORKER] ########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "(worker) C.U.M. UPDATER: Insufficient privilege. Skipping startup."
    exit
fi



####



################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /bin



echo "(worker) C.U.M. UPDATER: Installing new scripts..."



# MAKE SCRIPT FILES EXECUTABLE

chmod +x /minecraft/tmp/updatefiles/mc*
chmod +x /minecraft/tmp/updatefiles/cum*
chmod +x /minecraft/tmp/updatefiles/mcutils/*.sh
chmod +x /minecraft/tmp/updatefiles/run.sh



# REMOVE & RECREATE /bin/mcutils

rm -rf /bin/mcutils
mkdir /bin/mcutils



# COPY SCRIPT FILES TO /bin

cp /minecraft/tmp/updatefiles/cumupdate /bin/cumupdate
cp /minecraft/tmp/updatefiles/mcbackup /bin/mcbackup
cp /minecraft/tmp/updatefiles/mccreate /bin/mccreate
cp /minecraft/tmp/updatefiles/mcdelete /bin/mcdelete
cp /minecraft/tmp/updatefiles/mcpower /bin/mcpower
cp /minecraft/tmp/updatefiles/mcrestart /bin/mcrestart
cp /minecraft/tmp/updatefiles/mcstart /bin/mcstart
cp /minecraft/tmp/updatefiles/mcstop /bin/mcstop
cp /minecraft/tmp/updatefiles/mcupdate /bin/mcupdate

cp /minecraft/tmp/updatefiles/mcutils/backup.sh /bin/mcutils/backup.sh
cp /minecraft/tmp/updatefiles/mcutils/create.sh /bin/mcutils/create.sh
cp /minecraft/tmp/updatefiles/mcutils/delete.sh /bin/mcutils/delete.sh
cp /minecraft/tmp/updatefiles/mcutils/shutdown.sh /bin/mcutils/shutdown.sh
cp /minecraft/tmp/updatefiles/mcutils/start.sh /bin/mcutils/start.sh
cp /minecraft/tmp/updatefiles/mcutils/update.sh /bin/mcutils/update.sh
cp /minecraft/tmp/updatefiles/mcutils/warning.sh /bin/mcutils/warning.sh



sleep 1



################### STAGE 2: DEAL WITH THE CONFIGURATION FILE



# CHECK CONFIG FILE VERSIONS

INSTALLEDVER=$(cat /minecraft/cum.conf | grep "CFG_VER" | cut -d "=" -f 2)
NEWVER=$(cat /minecraft/tmp/updatefiles/cum.conf | grep "CFG_VER" | cut -d "=" -f 2)



# IF INSTALLED IS NEWER THAN DOWNLOADED

if (( $INSTALLEDVER > $NEWVER )); then
    echo "(worker) C.U.M. UPDATER: Installed config file is newer than downloaded config file. Leaving config file in inconsistent state. Please check the config file later."



# ELSE, INSTALLED IS OLDER THAN DOWNLOADED

elif (( $INSTALLEDVER < $NEWVER )); then
    echo "(worker) C.U.M. UPDATER: Updating configuration file..."

    I=$INSTALLEDVER

    while (( $I < $NEWVER ));
    do
        ((I++))
        cat /minecraft/tmp/updatefiles/confighistory/$I >> /minecraft/cum.conf
    done

    sed "s/.*CFG_VER=.*/CFG_VER=3/" /minecraft/cum.conf > /minecraft/cum.new
    rm /minecraft/cum.conf
    cp /minecraft/cum.new /minecraft/cum.conf && rm /minecraft/cum.new
fi



################### STAGE 3: DEAL WITH THE RUN SCRIPTS IN ALL SERVERS



echo "(worker) C.U.M. UPDATER: Checking server run scripts..."



for d in "/minecraft/servers/"*
do

    # CURRENT SERVER NAME

    SERVER=$(echo $(basename "$d"))



    # CHECK RUN FILE VERSIONS
    
    INSTALLEDVER=$(cat /minecraft/servers/$SERVER/run.sh | grep "RUN_VER" | cut -d "=" -f 2)
    NEWVER=$(cat /minecraft/tmp/updatefiles/run.sh | grep "RUN_VER" | cut -d "=" -f 2)



    # IF INSTALLED IS NEWER THAN DOWNLOADED

    if (( $INSTALLEDVER > $NEWVER )); then
        echo "(worker) C.U.M. UPDATER: Installed run script for server '$SERVER' is newer than downloaded config file. Leaving config file in inconsistent state. Please check the run script later."
    


    # ELSE, INSTALLED IS OLDER THAN DOWNLOADED

    elif (( $INSTALLEDVER < $NEWVER )); then
        CUSTOMJAR="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        DEFAULTJAR='$(cat /minecraft/jars/latest)'

        cp /minecraft/tmp/updatefiles/run.sh /minecraft/servers/$SERVER/run.sh

        sed -i "24s#.*#$CUSTOMJAR#" /minecraft/servers/$SERVER/run.sh
    fi

done



echo "(worker) C.U.M. UPDATER: Update complete."