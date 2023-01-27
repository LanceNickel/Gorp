#!/usr/bin/env bash

# THIS IS THE UN-INSTALLER SCRIPT!
# This should not need to be updated outside of updates to functionality of the program itself.



if [[ "$EUID" != 0 ]]; then
    echo "This uninstaller must be run as root. Use 'sudo !!' to do this again as root."
    exit
fi



sleep 1



echo -e "\nWelcome to The Minecraft C.U.M. (Commandline Utility Mechanism)"
sleep 2
echo -e "\nUninstalling..."

rm /bin/mcbackup
rm /bin/mcpower
rm /bin/mcrestart
rm /bin/mcstart
rm /bin/mcstop
rm /bin/mcupdate

rm -rf /bin/mcutils

rm -rf /minecraft



sleep 2

echo -e "\nThe Minecraft C.U.M. (Commandline Utility Mechanism) has been uninstalled.\n"