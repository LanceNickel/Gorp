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

if [ -d "/bin/mcutils" ]; then
    echo "Gorp is already installed."
    echo "If you're looking to update, please use updatecum.sh"
    exit
fi



# WELCOME

echo -e "\nWelcome to Gorp!"
sleep 0.5



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

mkdir /bin/gorputils
mkdir /bin/gorputils/action
mkdir /bin/gorputils/worker

if [ -d "/minecraft" ]; then
    WARN=true
else
    WARN=false
    mkdir /minecraft
    mkdir /minecraft/backups
    mkdir /minecraft/jars
    mkdir /minecraft/servers
    mkdir /minecraft/servers/server
fi



# MOVE FILES

cp action/* /bin/gorputils/action/
cp worker/* /bin/gorputils/worker/
cp help.txt /bin/gorputils/
cp gorp /bin/

cp gorp.conf /minecraft/
cp run.sh /minecraft/servers/server/run.sh

echo "paper-0-000.jar" > /minecraft/jars/latest



# RUN UPDATE ACTION TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."
sleep 1
/bin/gorputils/action/mcupdate

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
    echo -e "WARNING: '/minecraft' directory already exists. Refer to installation instructions for more info:\nhttps://github.com/LanceNickel/mc-cum/blob/main/readme.md\n"
fi
