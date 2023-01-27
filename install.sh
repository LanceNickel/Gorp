#!/usr/bin/env bash

# THIS IS THE INSTALLER SCRIPT!
# This should not need to be updated outside of updates to functionality of the program itself.



if [[ "$EUID" != 0 ]]; then
    echo "This installer must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



sleep 1



echo -e "\nWelcome to The Minecraft C.U.M. (Commandline Utility Mechanism)"
sleep 2

# Download required software...

echo -e "\nDownloading required software..."
sleep 2
echo
apt-get update
apt-get install apt-transport-https curl wget jq -y

sleep 2




# Install...

echo -e "\n\nInstalling..."


# Change permissions
chmod +x mc*
chmod +x -R mcutils/


# Create required directories
mkdir /bin/mcutils
mkdir /minecraft
mkdir /minecraft/backups
mkdir /minecraft/jars
mkdir /minecraft/servers
mkdir /minecraft/tmp
mkdir /minecraft/servers/server


# Move files to proper locations
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

mv run.sh /minecraft/servers/server/




# Clean up...
rm -rf mcutils




# Get server JAR file...

echo -e "Getting latest Paper JAR file..."


# Execute mcupdate to get latest file
sleep 1
echo
/bin/mcupdate

sleep 2




# Finished, but...

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