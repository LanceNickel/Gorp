#!/usr/bin/env bash

### [INSTALLER] ####################################################
#   Description:  Script that installs Gorp and dependencies :)
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Root guard

if [[ "$EUID" == 0 ]]; then
    echo "Please don't run as root or with sudo."
    exit 1
fi



#### Get sudo

echo "To install, Gorp will use sudo."
sudo whoami > /dev/null



#### Already installed

UPDATE="no"

if [[ -f "/usr/local/bin/gorp" ]] || [[ -d "/usr/local/bin/gorpmc/" ]] || [[ -f "/usr/local/etc/gorp.conf" ]]; then

    read -r -p "It looks like Gorp is already installed. Would you like to update? [y/N]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        UPDATE="yes"
    else
        UPDATE="no"
        exit 1
    fi

fi



#### Get user's OS homedir

HOMEDIR=~







####







#### INSTALL/UPDATE GORP ############

if [[ "$UPDATE" == "yes" ]]; then
    echo -e "\nUpdating Gorp..."
else
    echo -e "\nInstalling Gorp 0.8.1..."
fi



#### Make scripts executable

chmod +x ./action/*
chmod +x ./functions/*
chmod +x ./worker/*
chmod +x ./argparse.sh
chmod +x ./entry.sh
chmod +x ./run.sh
chmod +x ./gorp



#### Update homedir in gorp.conf and params.sh (only if not updating)

if [[ "$UPDATE" == "no" ]]; then

    sed -Ei "s:^HOMEDIR=.*$:HOMEDIR=$HOMEDIR/gorpmc:g" ./gorp.conf
    sed -Ei "s:^HOMEDIR=.*$:HOMEDIR=$HOMEDIR/gorpmc:g" ./functions/params.sh
    sed -Ei "s:^BACKUP_DEST=.*$:BACKUP_DEST=$HOMEDIR/gorpmc/backups:g" ./gorp.conf
    sed -Ei "s:^ARCHIVE_DEST=.*$:ARCHIVE_DEST=$HOMEDIR/gorpmc/archives:g" ./gorp.conf

fi

#### Set homedir in params.sh upon update, pulling value from current params.sh

if [[ "$UPDATE" == "yes" ]]; then
    CURRENT_HOMEDIR="$(cat /usr/local/bin/gorpmc/functions/params.sh | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)"
    sed -Ei "s:^HOMEDIR=.*$:HOMEDIR=$CURRENT_HOMEDIR:g" ./functions/params.sh
fi


#### Create dirs in /usr/local/bin/ & /usr/local/etc/ (delete first if updating)

if [[ "$UPDATE" == "yes" ]]; then
    sudo rm -rf /usr/local/bin/gorpmc/
    sudo rm /usr/local/bin/gorp
fi

sudo mkdir -p /usr/local/bin/gorpmc/
sudo mkdir -p /usr/local/bin/gorpmc/action/
sudo mkdir -p /usr/local/bin/gorpmc/functions/
sudo mkdir -p /usr/local/bin/gorpmc/worker/



#### Create gorp homedir (or set to warn if already exists) (only if not updating)

if [[ "$UPDATE" == "no" ]]; then

    if [[ -d "$HOMEDIR/gorpmc/" ]]; then
        WARN=true
    else
        WARN=false
        mkdir "$HOMEDIR"/gorpmc/
        mkdir "$HOMEDIR"/gorpmc/backups/
        mkdir "$HOMEDIR"/gorpmc/jars/
        mkdir "$HOMEDIR"/gorpmc/servers/
    fi

fi



#### Move the files to their installed directories

# /usr/local/bin/
sudo cp ./action/* /usr/local/bin/gorpmc/action/
sudo cp ./functions/* /usr/local/bin/gorpmc/functions/
sudo cp ./worker/* /usr/local/bin/gorpmc/worker/
sudo cp ./argparse.sh /usr/local/bin/gorpmc/
sudo cp ./entry.sh /usr/local/bin/gorpmc/
sudo cp ./gorp /usr/local/bin/
sudo cp ./help.txt /usr/local/bin/gorpmc/
sudo cp ./run.sh /usr/local/bin/gorpmc/







#### HANDLE CONFIG FILE ############

## Copy default config only if this is a fresh install

if [[ "$UPDATE" == "no" ]]; then
    cp ./gorp.conf "$HOMEDIR"/gorpmc/gorp.conf
fi


## Update the existing config file if this is an update

if [[ "$UPDATE" == "yes" ]]; then

    ## Get current values
    ## Expected: GAMEVER, RAM, MAX_RAM, BACKUP_DEST, ARCHIVE_DEST, UPDATE_FREQUENCY, TEXT_EDITOR

    ORIG_GAMEVER="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
    ORIG_RAM="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep -e '^RAM=' | cut -d '=' -f2)"
    ORIG_MAX_RAM="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep 'MAX_RAM=' | cut -d '=' -f2)"
    ORIG_BACKUP_DEST="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)"
    ORIG_ARCHIVE_DEST="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)"
    ORIG_TEXT_EDITOR="$(cat "$HOMEDIR"/gorpmc/gorp.conf | grep "^[^#;]" | grep 'TEXT_EDITOR=' | cut -d '=' -f2)"

    
    ## Set defaults if empty

    if [[ "$ORIG_GAMEVER" == "" ]]; then
        ORIG_GAMEVER="latest"
    fi

    if [[ "$ORIG_RAM" == "" ]]; then
        ORIG_RAM="4G"
    fi

    if [[ "$ORIG_MAX_RAM" == "" ]]; then
        ORIG_MAX_RAM="8G"
    fi

    if [[ "$ORIG_BACKUP_DEST" == "" ]]; then
        ORIG_BACKUP_DEST="$HOMEDIR/gorpmc/backups"
    fi

    if [[ "$ORIG_ARCHIVE_DEST" == "" ]]; then
        ORIG_ARCHIVE_DEST="$HOMEDIR/gorpmc/archives"
    fi

    if [[ "$ORIG_TEXT_EDITOR" == "" ]]; then
        ORIG_TEXT_EDITOR=""
    fi

    
    ## Update bundled config file

    sed -Ei "s:^GAMEVER=.*$:GAMEVER=$ORIG_GAMEVER:g" ./gorp.conf
    sed -Ei "s:^RAM=.*$:RAM=$ORIG_RAM:g" ./gorp.conf
    sed -Ei "s:^MAX_RAM=.*$:MAX_RAM=$ORIG_MAX_RAM:g" ./gorp.conf
    sed -Ei "s:^BACKUP_DEST=.*$:BACKUP_DEST=$ORIG_BACKUP_DEST:g" ./gorp.conf
    sed -Ei "s:^ARCHIVE_DEST=.*$:ARCHIVE_DEST=$ORIG_ARCHIVE_DEST:g" ./gorp.conf
    sed -Ei "s:^TEXT_EDITOR=.*$:TEXT_EDITOR=$ORIG_TEXT_EDITOR:g" ./gorp.conf


    ## Copy bundled config file to config file directory

    cp ./gorp.conf "$HOMEDIR"/gorpmc/gorp.conf    

fi







#### GET LATEST JAR FILE ############
#### (only if not updating)

if [[ "$UPDATE" == "no" ]]; then

    #### Set build to 000 to force a JAR download

    echo "paper-0-000.jar" > $HOMEDIR/gorpmc/jars/latest



    #### Get JAR file

    mkdir /tmp/gorp/

    echo -e "Getting latest Paper JAR file..."
    bash /usr/local/bin/gorpmc/action/mcupdatejar pleasedontdothis

    rm -rf /tmp/gorp/

fi







#### WE MADE IT ############

#### Print user intro (only if not updating)

if [[ "$UPDATE" == "no" ]]; then

    echo -e "\nINSTALLATION FINISHED\n\nCreate your first server with:  gorp create-server <server-name> [world-name]\nStart the server:               gorp start <server-name>\n\nRead more at https://gorp.lanickel.com/"

fi


#### Print warning if ~/gorpmc/ already existed (only if not updating)

if [[ "$UPDATE" == "no" ]]; then

    if [ $WARN = true ]; then
        echo -e "\n\nWARNING:\n'$HOMEDIR/gorpmc' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/getting-started/install/"
    fi

fi


#### Print update successful (if updating)

if [[ "$UPDATE" == "yes" ]]; then
    echo -e "\nGORP HAS UPDATED! Check the Gorp documentation at https://gorp.lanickel.com/ to ensure no further steps are required."
fi



#### Exit

exit 0
