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

echo "To do a few things for installation, Gorp needs sudo."
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



### APT-GET DEPENDENCIES

echo -e "\nDownloading required software..."
sudo apt-get update
sudo apt-get install apt-transport-https curl wget jq screen -y

sleep 2



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
    mkdir $HOMEDIR/
    mkdir $HOMEDIR/backups
    mkdir $HOMEDIR/jars
    mkdir $HOMEDIR/servers
fi



### MOVE FILES

sudo cp action/* /usr/local/bin/gorpmc/action/
sudo cp worker/* /usr/local/bin/gorpmc/worker/
sudo cp help.txt /usr/local/bin/gorpmc/
sudo cp gorp /usr/local/bin/

sudo mkdir -p /usr/local/etc/
sudo cp gorp.conf /usr/local/etc/

echo "paper-0-000.jar" > $HOMEDIR/jars/latest



### RUN UPDATE ACTION TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."
sleep 1
/usr/local/bin/gorpmc/action/mcupdatejar pleasedontdothis



### FINISHED, SHOW WARNING

echo -e "\nINSTALLATION FINISHED!\nHowever,"
sleep 1
echo -e "\nYOU"
sleep 0.5
echo "AREN'T"
sleep 0.5
echo "DONE"
sleep 0.5
echo "YET"
sleep 1
echo -e "\nPlease continue to follow the installation instructions.\n"

if [ $WARN = true ]; then
    echo -e "WARNING: '$HOMEDIR/gorpmc' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/getting-started/install/"
fi



exit 0