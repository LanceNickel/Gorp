#!/usr/bin/env bash

### [UNINSTALLER] ##################################################
#   Description:  Script that uninstalls Gorp :(
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    echo "Please do not run as root or with 'sudo'. Gorp will ask for sudo rights if it needs it. Exit (10)."
    exit 10
fi



### GET SUDO PERMISSIONS

echo "To uninstall, Gorp needs sudo."
sudo whoami > /dev/null



####



echo -e "Uninstalling..."



# REMOVE GORP FROM /usr/local/bin (/minecraft is never deleted to avoid catastrophic data loss)

sudo rm -rf /usr/local/bin/gorpmc/
sudo rm /usr/local/bin/gorp



sleep 1



echo -e "Gorp has been uninstalled. Minecraft files have been preserved."
exit 0