#!/usr/bin/env bash

### [UNINSTALLER] ##################################################
#   Description:  Script that uninstalls Gorp :(
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "This uninstaller must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



####




# WELCOME

echo -e "Welcome to Gorp!"
sleep 0.5



echo -e "\nUninstalling..."



# REMOVE GORP FROM /usr/local/bin (/minecraft is never deleted to avoid catastrophic data loss)

rm -rf /usr/local/bin/gorputils/
rm /usr/local/bin/gorp



sleep 1

echo -e "Gorp has been uninstalled. Minecraft files have been preserved."