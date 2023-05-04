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

if [[ -d "/usr/local/bin/gorp" ]]; then
    echo -e "Gorp is already installed. To update, run 'sudo gorp upgrade'.\nRunning into problems? Open an issue: https://github.com/LanceNickel/Gorp/issues\nOr send me an email: gorp@lanickel.com"
    exit 1
fi



#### Get user's OS homedir

HOMEDIR=~







####







#### INSTALL GORP ############

echo -e "\nInstalling Gorp..."



#### Make scripts executable

chmod +x action/*
chmod +x functions/*
chmod +x worker/*
chmod +x argparse.sh
chmod +x entry.sh
chmod +x run.sh
chmod +x gorp



#### Update homedir in gorp.conf

sed -i "s:BOBSBURGERS:$HOMEDIR/gorpmc:g" gorp.conf



#### Create dirs in /usr/local/bin/ & /usr/local/etc/

sudo mkdir -p /usr/local/bin/gorpmc/
sudo mkdir -p /usr/local/bin/gorpmc/action/
sudo mkdir -p /usr/local/bin/gorpmc/functions/
sudo mkdir -p /usr/local/bin/gorpmc/worker/
sudo mkdir -p /usr/local/etc/



#### Create gorp homedir (or set to warn if already exists)

if [[ -d "$HOMEDIR/gorpmc/" ]]; then
    WARN=true
else
    WARN=false
    mkdir $HOMEDIR/gorpmc/
    mkdir $HOMEDIR/gorpmc/backups/
    mkdir $HOMEDIR/gorpmc/jars/
    mkdir $HOMEDIR/gorpmc/servers/
fi



#### Move the files to their installed directories

# /usr/local/bin/
sudo cp action/* /usr/local/bin/gorpmc/action/
sudo cp functions/* /usr/local/bin/gorpmc/functions/
sudo cp worker/* /usr/local/bin/gorpmc/worker/
sudo cp argparse.sh /usr/local/bin/gorpmc/
sudo cp entry.sh /usr/local/bin/gorpmc/
sudo cp gorp /usr/local/bin/
sudo cp help.txt /usr/local/bin/gorpmc/
sudo cp run.sh /usr/local/bin/gorpmc/

# /usr/local/etc/
sudo cp gorp.conf /usr/local/etc/







#### GET LATEST JAR FILE ############

#### Set build to 000 to force a JAR download

echo "paper-0-000.jar" > $HOMEDIR/gorpmc/jars/latest



#### Get JAR file

mkdir /tmp/gorp/

echo -e "Getting latest Paper JAR file..."
bash /usr/local/bin/gorpmc/action/mcupdatejar pleasedontdothis

rm -rf /tmp/gorp/







#### WE MADE IT ############

#### Print user intro

echo -e "\nINSTALLATION FINISHED\n\nCreate your first server with:    gorp create-server [server-name] <world-name>\nStart the server                  gorp start [server-name]\n\nRead more at https://gorp.lanickel.com/"



#### Print warning if ~/gorpmc/ already existed

if [ $WARN = true ]; then
    echo -e "\n\nWARNING:\n'$HOMEDIR/gorpmc' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/getting-started/install/"
fi



#### Exit

exit 0