#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name
#   Parameters:   2: (required) World name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "s3zujKM87FD56sxb" ]]; then
    echo "createserver.sh: Cannot be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
WORLD=$3



####


# CREATE SERVER DIRECTORY AND COPY RUN.SH

mkdir $HOMEDIR/servers/$SERVER
cp /usr/local/bin/gorpmc/worker/run.sh $HOMEDIR/servers/$SERVER/



# PREPARE KEY FILES
# It is not possible to get to this part of code execution without first agreeing to the Minecraft EULA via a prompt.
# Users who did not expressly agree to the EULA did not get here, as they would not have been able to execute this script with the key (reasonably).

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt
touch $HOMEDIR/servers/$SERVER/server.properties



echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties



echo "Server created!"