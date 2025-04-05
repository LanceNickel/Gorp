#!/usr/bin/env bash

### [UNINSTALLER] ##################################################
#   Description:  Script that uninstalls Gorp :(
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    echo "Please do not run as root or with 'sudo'"
    exit 1
fi



### GET SUDO PERMISSIONS

echo "To uninstall, Gorp will use sudo."
sudo whoami > /dev/null



####



echo -e "Uninstalling..."



# REMOVE GORP FROM /usr/local/bin (~/gorpmc is never deleted to avoid catastrophic data loss)

sudo rm -rf /usr/local/bin/gorpmc/
sudo rm /usr/local/bin/gorp
sudo rm /usr/local/etc/gorp.conf



sleep 1



echo -e "Gorp has been uninstalled. Minecraft files have been preserved."
exit 0
