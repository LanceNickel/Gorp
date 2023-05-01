#!/usr/bin/env bash

### [INSTALLER] ####################################################
#   Description:  Script that installs Gorp and dependencies :)
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    echo "Please don't run as root or with sudo."
    exit 1
fi



### GET SUDO PERMISSIONS

echo "To install, Gorp will use sudo."
sudo whoami > /dev/null



### ALREADY INSTALLED GUARD

if [[ -d "/usr/local/bin/gorp" ]]; then
    echo -e "Gorp is already installed. To update, run 'sudo gorp upgrade'.\nRunning into problems? Open an issue: https://github.com/LanceNickel/Gorp/issues\nOr send me an email: gorp@lanickel.com"
    exit 1
fi



#### SCRIPT PARAMETERS ################

HOMEDIR=~



####



### WELCOME

echo -e "\nInstalling Gorp..."



### MAKE SCRIPTS EXECUTABLE

chmod +x action/*
chmod +x worker/*
chmod +x entry.sh
chmod +x argparse.sh
chmod +x gorp



### UPDATE HOMEDIR OPTIONS IN gorp.conf

sed -i "s:BOBSBURGERS:$HOMEDIR/gorpmc:g" gorp.conf



### CREATE REQUIRED DIRS

sudo mkdir -p /usr/local/bin/gorpmc/
sudo mkdir -p /usr/local/bin/gorpmc/action/
sudo mkdir -p /usr/local/bin/gorpmc/worker/

if [[ -d "$HOMEDIR/gorpmc" ]]; then
    WARN=true
else
    WARN=false
    mkdir $HOMEDIR/gorpmc/
    mkdir $HOMEDIR/gorpmc/backups
    mkdir $HOMEDIR/gorpmc/jars
    mkdir $HOMEDIR/gorpmc/servers
fi



### MOVE FILES

sudo cp action/* /usr/local/bin/gorpmc/action/
sudo cp worker/* /usr/local/bin/gorpmc/worker/
sudo cp help.txt /usr/local/bin/gorpmc/
sudo cp argparse.sh /usr/local/bin/gorpmc/
sudo cp entry.sh /usr/local/bin/gorpmc/
sudo cp gorp /usr/local/bin/

sudo mkdir -p /usr/local/etc/
sudo cp gorp.conf /usr/local/etc/

echo "paper-0-000.jar" > $HOMEDIR/gorpmc/jars/latest



### RUN UPDATE ACTION TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh || echo "Installation error -- Failed to get new config paremeters. Please uninstall Gorp and try again. If this issue persists, open an issue." && exit 1

source /usr/local/bin/gorpmc/action/mcupdatejar pleasedontdothis



### FINISHED, SHOW WARNING

echo -e "\nINSTALLATION FINISHED\n\nCreate your first server with:    gorp create-server [server-name] <world-name>\nStart the server                  gorp start [server-name]\n\nRead more at https://gorp.lanickel.com/"


if [ $WARN = true ]; then
    echo -e "\n\nWARNING:\n'$HOMEDIR/gorpmc' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/getting-started/install/"
fi



exit 0