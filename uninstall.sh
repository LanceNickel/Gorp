#!/usr/bin/env bash

### [UNINSTALLER] ##################################################
#   Description:  Worker that uninstalls all aspects of C.U.M.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "This uninstaller must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



####




# WELCOME

echo -e "Welcome to The Minecraft C.U.M. (Commandline Utility Mechanism)"
sleep 0.5



echo -e "\nUninstalling..."



# REMOVE THE C.U.M.

rm /bin/mcbackup
rm /bin/mcpower
rm /bin/mcrestart
rm /bin/mcstart
rm /bin/mcstop
rm /bin/mcupdate
rm /bin/cumupdate
rm -rf /bin/mcutils



sleep 1

echo -e "The Minecraft C.U.M. (Commandline Utility Mechanism) has been uninstalled."