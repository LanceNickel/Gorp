#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "create.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1



####



# TMP DIRECTORY

rm -rf /minecraft/tmp
mkdir /minecraft/tmp



# GET LATEST RUN.SH

echo "create.sh: Creating new server at '/minecraft/servers/$SERVER/'"

wget -q https://raw.githubusercontent.com/LanceNickel/Gorp/main/run.sh -P /minecraft/tmp/



# CREATE SERVER DIRECTORY AND MOVE RUN.SH

mkdir /minecraft/servers/$SERVER
chmod +x /minecraft/tmp/run.sh
cp /minecraft/tmp/run.sh /minecraft/servers/$SERVER/run.sh



# INDICATE USER'S AGREEMENT TO EULA
# It is not possible to get to this part of code execution without first agreeing to the Minecraft EULA via a prompt.
# Users who did not expressly agree to the EULA did not get here, as they would not have been able to execute this script with the key.

echo "eula=true" > /minecraft/servers/$SERVER/eula.txt



# CLEAN UP

rm -rf /minecraft/tmp



echo "create.sh: Creation complete."