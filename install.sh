#!/usr/bin/env bash

### [INSTALLER] ####################################################
#   Description:  Script that installs Gorp and dependencies :)
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "This installer must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



####



# ALREADY INSTALLED GUARD

if [ -d "/usr/local/bin/gorputils" ]; then
    echo -e "Gorp is already installed. To update, run 'sudo gorp upgrade'.\nRunning into problems? Open an issue: https://github.com/LanceNickel/Gorp/issues\nOr send me an email: gorp@lanickel.com"
    exit
fi



# WELCOME

echo -e "\nWelcome to Gorp!"
sleep 0.5



# USER EULA AND AGREEMENT GUARD

echo -e "\n==== IMPORTANT! ====\nTo continue you must agree to the Minecraft EULA (https://aka.ms/MinecraftEULA).\nYou must also agree to use Gorp for PERSONAL USE ONLY."

read -r -p "Do you agree to the Minecraft EULA? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    echo "You did not agree to the Minecraft EULA. Exiting."
    exit
fi

read -r -p "Do you agree to use Gorp for personal use only? COMMERCIAL USE PROHIBITED. [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    echo "Gorp is for personal use. If you are an interested commercial entity, please reach out to gorp@lanickel.com"
    exit
fi



# APT-GET DEPENDENCIES

echo -e "\nDownloading required software..."
sleep 0.5
apt-get update
apt-get install apt-transport-https curl wget jq screen -y

sleep 2



echo -e "Installing..."



# MAKE SCRIPTS +X

chmod +x action/*
chmod +x worker/*
chmod +x gorp
chmod +x run.sh



# CREATE REQUIRED DIRS

mkdir -p /usr/local/bin/gorputils
mkdir -p /usr/local/bin/gorputils/action
mkdir -p /usr/local/bin/gorputils/worker

if [ -d "/minecraft" ]; then
    WARN=true
else
    WARN=false
    mkdir /minecraft
    mkdir /minecraft/backups
    mkdir /minecraft/jars
    mkdir /minecraft/servers
fi



# MOVE FILES

cp action/* /usr/local/bin/gorputils/action/
cp worker/* /usr/local/bin/gorputils/worker/
cp help.txt /usr/local/bin/gorputils/
cp gorp /usr/local/bin/

cp gorp.conf /minecraft/
cp run.sh /minecraft/servers/server/run.sh

echo "paper-0-000.jar" > /minecraft/jars/latest



# RUN UPDATE ACTION TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."
sleep 1
/usr/local/bin/gorputils/action/mcupdatejar

sleep 2



# FINISHED, SHOW WARNING

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
    echo -e "WARNING: '/minecraft' directory already exists. Refer to installation instructions for more info:\nhttps://gorp.lanickel.com/"
fi
