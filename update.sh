#!/usr/bin/env bash

### [C.U.M. UPDATE WORKER] ########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "(worker) GORP UPDATER: Insufficient privilege. Skipping startup."
    exit
fi



####



################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /bin



echo "(worker) GORP UPDATER: Installing new scripts..."



# MAKE SCRIPT FILES EXECUTABLE

chmod +x /minecraft/tmp/updatefiles/action/*
chmod +x /minecraft/tmp/updatefiles/worker/*
chmod +x /minecraft/tmp/updatefiles/run.sh



# REMOVE & RECREATE DIRS IN /bin

rm -rf /bin/gorputils
mkdir /bin/gorputils/action
mkdir /bin/gorputils/worker



# COPY SCRIPT FILES TO /bin

cp action/* /bin/gorputils/action/
cp worker/* /bin/gorputils/worker/
cp gorp /bin/



sleep 1



################### STAGE 2: DEAL WITH THE CONFIGURATION FILE



# CHECK CONFIG FILE VERSIONS

INSTALLEDVER=$(cat /minecraft/gorp.conf | grep "CFG_VER" | cut -d "=" -f2)
NEWVER=$(cat /minecraft/tmp/updatefiles/gorp.conf | grep "CFG_VER" | cut -d "=" -f2)



# IF INSTALLED IS NEWER THAN DOWNLOADED

if (( $INSTALLEDVER > $NEWVER )); then
    echo "(worker) GORP UPDATER: Installed config file is newer than downloaded config file. Leaving config file in inconsistent state. Please check the config file later."



# ELSE, INSTALLED IS OLDER THAN DOWNLOADED

elif (( $INSTALLEDVER < $NEWVER )); then
    echo "(worker) GORP UPDATER: Updating configuration file..."

    I=$INSTALLEDVER

    while (( $I < $NEWVER ));
    do
        ((I++))
        cat /minecraft/tmp/updatefiles/confighistory/$I >> /minecraft/gorp.conf
    done

    sed -i "s/.*CFG_VER=.*/CFG_VER=3/" /minecraft/gorp.conf
fi



################### STAGE 3: DEAL WITH THE RUN SCRIPTS IN ALL SERVERS



echo "(worker) GORP UPDATER: Checking server run scripts..."



for d in "/minecraft/servers/"*
do

    # CURRENT SERVER NAME

    SERVER=$(echo $(basename "$d"))



    # CHECK RUN FILE VERSIONS
    
    INSTALLEDVER=$(cat /minecraft/servers/$SERVER/run.sh | grep "RUN_VER" | cut -d "=" -f 2)
    NEWVER=$(cat /minecraft/tmp/updatefiles/run.sh | grep "RUN_VER" | cut -d "=" -f 2)



    # IF INSTALLED IS NEWER THAN DOWNLOADED

    if (( $INSTALLEDVER > $NEWVER )); then
        echo "(worker) GORP UPDATER: Installed run script for server '$SERVER' is newer than downloaded config file. Leaving config file in inconsistent state. Please check the run script later."
    


    # ELSE, INSTALLED IS OLDER THAN DOWNLOADED

    elif (( $INSTALLEDVER < $NEWVER )); then
        CUSTOMJAR="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        CUSTOMRAM="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

        cp /minecraft/tmp/updatefiles/run.sh /minecraft/servers/$SERVER/run.sh

        sed -i "32s#.*#$CUSTOMJAR#" /minecraft/servers/$SERVER/run.sh
        sed -i "42s#.*#$CUSTOMRAM#" /minecraft/servers/$SERVER/run.sh
    fi

done



echo "(worker) GORP UPDATER: Update complete."
