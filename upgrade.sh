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
    echo "upgrade.sh: Insufficient privilege. Exiting."
    exit
fi



####



################### STAGE 0: DETECT IF THIS IS AN OLDER INSTALLATION (/bin)

if [ -d "/bin/gorputils" ]; then
    rm -rf /bin/gorputils
    rm /bin/gorp
fi



################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /usr/local/bin/



echo "upgrade.sh: Upgrading Gorp..."



# MAKE SCRIPT FILES EXECUTABLE

chmod +x /minecraft/tmp/updatefiles/action/*
chmod +x /minecraft/tmp/updatefiles/worker/*
chmod +x /minecraft/tmp/updatefiles/gorp
chmod +x /minecraft/tmp/updatefiles/run.sh



# REMOVE CURRENT INSTALLATION

rm -rf /usr/local/bin/gorputils
rm /usr/local/bin/gorp



# CREATE DIRECTORIES AND RE-INSTALL GORP

mkdir /usr/local/bin/gorputils
mkdir /usr/local/bin/gorputils/action
mkdir /usr/local/bin/gorputils/worker

cp /minecraft/tmp/updatefiles/action/* /usr/local/bin/gorputils/action/
cp /minecraft/tmp/updatefiles/worker/* /usr/local/bin/gorputils/worker/
cp /minecraft/tmp/updatefiles/help.txt /usr/local/bin/gorputils/
cp /minecraft/tmp/updatefiles/gorp /usr/local/bin/



sleep 1



################### STAGE 2: DEAL WITH THE CONFIGURATION FILE

# Store currently set values in config

GAMEVER_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
RAM_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)"
BACKUPS_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'BACKUPS=\|DEST=' | cut -d '=' -f2)"
ARCHIVES_ORIG="$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'ARCHIVES=' | cut -d '=' -f2)"



# Copy the new config over

cp /minecraft/tmp/updatefiles/gorp.conf /minecraft/gorp.conf



# Deal with the OG settings (will always be there)

sed -i "20s:.*:GAMEVER=$GAMEVER_ORIG:" /minecraft/gorp.conf
sed -i "30s:.*:RAM=$RAM_ORIG:" /minecraft/gorp.conf
sed -i "40s:.*:BACKUPS=$BACKUPS_ORIG:" /minecraft/gorp.conf



# If ARCHIVES existed, replace the value, otherwise leave the default from the copied file

if [ "$ARCHIVES_ORIG" != "" ]; then
    sed -i "50s:.*:ARCHIVES=$ARCHIVES_ORIG:" /minecraft/gorp.conf
fi









################### STAGE 3: DEAL WITH THE RUN SCRIPTS IN ALL SERVERS

for d in "/minecraft/servers/"*
do

    SERVER=$(echo $(basename "$d"))

    JAR_ORIG="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
    RAM_ORIG="$(cat /minecraft/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

    cp /minecraft/tmp/updatefiles/run.sh /minecraft/servers/$SERVER/run.sh

    sed -i "20s:.*:$JAR_ORIG:" /minecraft/servers/$SERVER/run.sh
    sed -i "29s:.*:$RAM_ORIG:" /minecraft/servers/$SERVER/run.sh

done



echo "upgrade.sh: Gorp upgrade complete."
