#!/usr/bin/env bash

### [ARCHIVE-WORLD WORKER] ########################################
#   Description:  Worker script that performs the world archival.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







#### SCRIPT PARAMETERS ################

SERVER=$2
WORLD_TO_ARCHIVE=$3

OPTIONS=$(worldOptions "$SERVER")







####







### IF WORLD_TO_ARCHIVE NOT SPECIFIED, ASK USER

if [[ "$WORLD_TO_ARCHIVE" == "" ]]; then
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
    done
fi







### COMPRESS THE WORLD FILES

echo "Copying files for $WORLD_TO_ARCHIVE..."

cp -r $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ to $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/"
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ to $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/"
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ to $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/"

echo "Compressing files..."

cd $HOMEDIR/tmp || handle_error "Failed to cd to $HOMEDIR/tmp"
tar -czf $WORLD_TO_ARCHIVE.tar.gz $WORLD_TO_ARCHIVE >/dev/null 2>/dev/null || handle_error "Failed to compress archive files in $HOMEDIR/tmp"







### MAKE SURE ARCHIVE DESTINATION EXISTS

mkdir -p $ARCHIVE_DEST/$SERVER || handle_error "Failed to mkdir at $ARCHIVE_DEST/$SERVER"







### COPY THE WORLD FILES TO DESTINATION

echo "Moving archive to destination..."

cp $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz $ARCHIVE_DEST/$SERVER/ || handle_error "Failed to cp to $ARCHIVE_DEST/$SERVER/"







### ARCHIVE INTEGRITY GUARD

CHECKSUM=$(md5sum $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)
TESTSUM=$(md5sum $ARCHIVE_DEST/$SERVER/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)

if [[ "$CHECKSUM" != "$TESTSUM" ]]; then
    handle_error "Archived files in destination failed checksum test."
fi







echo "World archived!"