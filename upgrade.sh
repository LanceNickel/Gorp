#!/usr/bin/env bash

### [GORP UPGRADE WORKER] #########################################
#   Description:  Worker script that performs the upgrade tasks.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "(worker) GORP UPGRADER: Insufficient privilege. Skipping startup."
    exit
fi



####



################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /bin



echo "(worker) GORP UPGRADER: Installing new scripts..."



# MAKE SCRIPT FILES EXECUTABLE

chmod +x /minecraft/tmp/updatefiles/action/*
chmod +x /minecraft/tmp/updatefiles/worker/*
chmod +x /minecraft/tmp/updatefiles/run.sh



# REMOVE & RECREATE DIRS IN /bin

rm -rf /bin/gorputils
mkdir /bin/gorp
mkdir /bin/gorputils/action
mkdir /bin/gorputils/worker



# COPY SCRIPT FILES TO /bin

cp action/* /bin/gorputils/action/
cp worker/* /bin/gorputils/worker/
cp gorp /bin/



sleep 1



################### STAGE 2: DEAL WITH THE CONFIGURATION FILE

GAMEVER_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=')"
RAM_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=')"
DEST_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'DEST=')"

cp /minecraft/tmp/updatefiles/gorp.conf /minecraft/gorp.conf

sed -i "19s#.*#$GAMEVER_ORIG#" /minecraft/gorp.conf
sed -i "29s#.*#$RAM_ORIG#" /minecraft/gorp.conf
sed -i "39s#.*#$DEST_ORIG#" /minecraft/gorp.conf



################### STAGE 3: DEAL WITH THE RUN SCRIPTS IN ALL SERVERS



echo "(worker) GORP UPGRADER: Checking server run scripts..."



for d in "/minecraft/servers/"*
do

    SERVER=$(echo $(basename "$d"))

    JAR_ORIG="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
    RAM_ORIG="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

    cp /minecraft/tmp/updatefiles/run.sh /minecraft/servers/$SERVER/run.sh

    sed -i "20s#.*#$JAR_ORIG#" /minecraft/servers/$SERVER/run.sh
    sed -i "29s#.*#$RAM_ORIG#" /minecraft/servers/$SERVER/run.sh

done



echo "(worker) GORP UPGRADER: Update complete."
