#!/usr/bin/env bash

### [INSTALLER] ####################################################
#   Description:  Installs dependencies and installs script files.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "This installer must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



####



# ALREADY INSTALLED GUARD
if [ -d "/bin/mcutils" ]; then
    echo "The C.U.M. is already installed."
    echo "If you're looking to update, please use updatecum.sh"
    exit
fi



# WELCOME

echo -e "\nWelcome to The Minecraft C.U.M. (Commandline Utility Mechanism)"
sleep 0.5



# APT-GET DEPENDENCIES

echo -e "\nDownloading required software..."
sleep 0.5
apt-get update
apt-get install apt-transport-https curl wget jq screen -y

sleep 2



echo -e "Installing..."



# MAKE SCRIPTS +X

chmod +x mc*
chmod +x cumupdate
chmod +x -R mcutils/
chmod +x *.sh



# CREATE REQUIRED DIRS

mkdir /bin/mcutils

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

cp mcbackup /bin/mcbackup
cp mcpower /bin/mcpower
cp mcrestart /bin/mcrestart
cp mcstart /bin/mcstart
cp mcstop /bin/mcstop
cp mcupdate /bin/mcupdate
cp cumupdate /bin/cumupdate

cp mcutils/backup.sh /bin/mcutils/backup.sh
cp mcutils/shutdown.sh /bin/mcutils/shutdown.sh
cp mcutils/start.sh /bin/mcutils/start.sh
cp mcutils/update.sh /bin/mcutils/update.sh
cp mcutils/warning.sh /bin/mcutils/warning.sh

cp cum.conf /minecraft
cp run.sh /minecraft/servers/server/



# RUN MCUPDATE TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."
sleep 1
/bin/mcupdate

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