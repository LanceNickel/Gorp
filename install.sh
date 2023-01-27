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



# WELCOME

echo -e "\NWelcome to The Minecraft C.U.M. (Commandline Utility Mechanism)"
sleep 0.5



# APT-GET DEPENDENCIES

echo -e "\nDownloading required software..."
sleep 0.5
apt-get update
apt-get install apt-transport-https curl wget jq screen -y

sleep 2



echo -e "\n\nInstalling..."



# MAKE SCRIPTS +X

chmod +x mc*
chmod +x -R mcutils/
chmod +x *.sh



# CREATE REQUIRED DIRS

mkdir /bin/mcutils
mkdir /minecraft
mkdir /minecraft/backups
mkdir /minecraft/jars
mkdir /minecraft/servers
mkdir /minecraft/tmp
mkdir /minecraft/servers/server



# MOVE FILES

mv mcbackup /bin/mcbackup
mv mcpower /bin/mcpower
mv mcrestart /bin/mcrestart
mv mcstart /bin/mcstart
mv mcstop /bin/mcstop
mv mcupdate /bin/mcupdate

mv mcutils/backup.sh /bin/mcutils/backup.sh
mv mcutils/shutdown.sh /bin/mcutils/shutdown.sh
mv mcutils/start.sh /bin/mcutils/start.sh
mv mcutils/update.sh /bin/mcutils/update.sh
mv mcutils/warning.sh /bin/mcutils/warning.sh

mv cum.conf /minecraft
mv run.sh /minecraft/servers/server/



# CLEAN UP
rm -rf mcutils



# RUN MCUPDATE TO GET & SET JAR FILE

echo -e "Getting latest Paper JAR file..."
sleep 1
/bin/mcupdate

sleep 2



# FINISHED, SHOW WARNING

echo -e "INSTALLATION FINISHED!\nHowever,"
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
