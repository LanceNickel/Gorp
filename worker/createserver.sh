#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name
#   Parameters:   2: (required) World name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# KEY GUARD (to double-check user's agreement to EULA)

if [ "$3" != "s3zujKM87FD56sxb" ]; then
        echo "create.sh: Incorrect key. This script is not meant to be directly executed by the user. Exiting."
        exit
fi



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "create.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD=$2



####


# CREATE SERVER DIRECTORY AND COPY RUN.SH

mkdir $HOMEDIR/servers/$SERVER
cp /usr/local/bin/gorpmc/worker/run.sh $HOMEDIR/servers/$SERVER/



# PREPARE KEY FILES
# It is not possible to get to this part of code execution without first agreeing to the Minecraft EULA via a prompt.
# Users who did not expressly agree to the EULA did not get here, as they would not have been able to execute this script with the key.

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt
touch $HOMEDIR/servers/$SERVER/server.properties



echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties



echo "create.sh: Creation complete."