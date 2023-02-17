#!/usr/bin/env bash

### [ARCHIVE-WORLD WORKER] ########################################
#   Description:  Worker script that performs the world archival.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "archiveworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD_TO_ARCHIVE=$2

OPTIONS=$(ls /minecraft/servers/$SERVER/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)
DEST=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'ARCHIVES=' | cut -d '=' -f2)



####



# MAKE SURE ARCHIVE ROOT DESTINATION EXISTS

mkdir -p $DEST



# IF WORLD_TO_ARCHIVE NOT SPECIFIED, ASK USER

if [ "$WORLD_TO_ARCHIVE" == "" ]; then
    while [ true ]
    do
        echo -e "Options:\n$OPTIONS"

        read -r -p "Please enter a world to archive: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_ARCHIVE=$response
            break
        else
            echo -e "\nSpecified world does not exist.\n"
        fi
fi



# CREATE TMP DIRECTORY

rm -rf /minecraft/tmp
mkdir -p /minecraft/tmp/$WORLD



# COMPRESS THE WORLD FILES

echo "archiveworld.sh: Archiving $WORLD..."

cp -r /minecraft/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ /minecraft/tmp/$WORLD/
cp -r /minecraft/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ /minecraft/tmp/$WORLD/
cp -r /minecraft/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ /minecraft/tmp/$WORLD/

cd /minecraft/tmp
tar -czf $WORLD.tar.gz $WORLD >/dev/null 2>/dev/null



# COPY THE WORLD FILES TO DESTINATION

echo "archiveworld.sh: Moving world to archive destination... ($DEST/$WORLD.tar.gz)"

cp /minecraft/tmp/$WORLD.tar.gz $DEST/



# ARCHIVE INTEGRITY GUARD

CHECKSUM=$(md5sum /minecraft/tmp/$WORLD.tar.gz | cut -d ' ' -f1)
TESTSUM=$(md5sum $DEST/$WORLD.tar.gz | cut -d ' ' -f1)

if [ "$CHECKSUM" != "$TESTSUM" ]; then
    echo "archiveworld.sh: Checksum failed. Ensure the archive destination directory is correctly configured. Exiting."
    exit
fi



# CLEAN UP

rm -rf /minecraft/servers/$SERVER/world-$WORLD_TO_ARCHIVE
rm -rf /minecraft/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether
rm -rf /minecraft/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end

rm -rf /minecraft/tmp



echo "archiveworld.sh: World archived."