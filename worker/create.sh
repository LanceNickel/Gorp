#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "(worker) CREATE: Insufficient privilege. Creation failed."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1



####



# TMP DIRECTORY

rm -rf /minecraft/tmp
mkdir /minecraft/tmp



# GET LATEST RUN.SH

echo "(worker) CREATE: Creating new server at '/minecraft/servers/$SERVER/'"

wget -q https://raw.githubusercontent.com/LanceNickel/mc-cum/main/run.sh -P /minecraft/tmp/



# CREATE SERVER DIRECTORY AND MOVE RUN.SH

mkdir /minecraft/servers/$SERVER
chmod +x /minecraft/tmp/run.sh
cp /minecraft/tmp/run.sh /minecraft/servers/$SERVER/run.sh



# CLEAN UP

rm -rf /minecraft/tmp



echo "(worker) CREATE: Creation complete."