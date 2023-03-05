#!/usr/bin/env bash

### [INSTALLER] ####################################################
#   Description:  Script that installs Gorp and dependencies :)
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    echo "Please don't run as root or with sudo. Exit (10)."
    exit 10
fi



### GET SUDO PERMISSIONS

echo "To install, Gorp will use sudo."
sudo whoami > /dev/null



### ALREADY INSTALLED GUARD

if [[ -d "/usr/local/bin/gorp" ]]; then
    echo -e "Gorp is already installed. To update, run 'sudo gorp upgrade'.\nRunning into problems? Open an issue: https://github.com/LanceNickel/Gorp/issues\nOr send me an email: gorp@lanickel.com"
    exit 21
fi



#### SCRIPT PARAMETERS ################

HOMEDIR=~



####



### WELCOME

echo -e "\nWelcome to Gorp!"



### USER EULA AND AGREEMENT RT-GUARD

if [[ "$1" != "testtesttest" ]]; then

    echo -e "\n==== IMPORTANT! ====\nTo continue you must agree to the Minecraft EULA (https://aka.ms/MinecraftEULA).\nYou must also agree to use Gorp for PERSONAL USE ONLY."

    read -r -p "Do you agree to the Minecraft EULA? [y/n]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sleep 0.25
    else
        echo "You answered the prompt wrong! Exit (16)."
        exit 16
    fi

    read -r -p "Do you agree to use Gorp for personal use only? COMMERCIAL USE PROHIBITED. [y/n]: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sleep 0.25
    else
        echo "You answered the prompt wrong! Exit (16)."
        exit 12
    fi

fi



echo "Installing..."



### MAKE SCRIPTS EXECUTABLE

chmod +x action/*
chmod +x worker/*
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
sudo cp gorp /usr/local/bin/

sudo mkdir -p /usr/local/etc/
sudo cp gorp.conf /usr/local/etc/

echo "paper-0-000.jar" > $HOMEDIR/gorpmc/jars/latest



### RUN UPDATE ACTION TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."

/usr/local/bin/gorpmc/action/mcupdatejar pleasedontdothis



### FINISHED, SHOW WARNING

echo -e "\nINSTALLATION FINISHED\n\nCreate your first server with:    gorp create-server [server-name] <world-name>\nStart the server                  gorp start [server-name]\n\nRead more at https://gorp.lanickel.com/"


if [ $WARN = true ]; then
    echo -e "\n\nWARNING:\n'$HOMEDIR/gorpmc' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/getting-started/install/"
fi



exit 0