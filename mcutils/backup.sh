#!/usr/bin/env bash

# THIS IS THE MAIN BACKUP SCRIPT!
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# 1: Server directory name, required!



if [[ "$EUID" != 0 ]]; then
        echo "(worker) BACKUP: Insufficient privilege. Backup failed."
        exit
fi


# Get global varibles
/minecraft/cum.conf

SERVER=$1
WORLD=$(cat /minecraft/servers/$SERVER/server.properties | grep "level-name" | cut -d "=" -f2)

YEAR=$(date +"%Y")
MONTH=$(date +"%m")

BACKUP=$(echo "$WORLD-$DATE_FILE")
SOURCE=$(echo "/minecraft/servers/$SERVER/$WORLD")
DEST=$(cat /minecraft/cum.conf | grep "^[^#;]" | grep 'DEST=' | cut -d '=' -f 2)
FULL_DEST=$(echo "$DEST/$WORLD/$YEAR/$MONTH")
TMP=$(echo "/minecraft/tmp/backup")



if [ -d "$SOURCE" ]; then
        sleep 0.005
else
        echo "(worker) BACKUP: Source directory does not exist. Backup failed."
        exit
fi



echo "(worker) BACKUP: Starting backup..."



if [ -d "$DEST" ]; then
        # everything is here, we can continue
        sleep 0.005

elif [ -d "$DEST_ROOT/$WORLD/$YEAR" ]; then
        # month dir doesn't exist, since rest of path exists, create destination path
        mkdir $DEST

elif [ -d "$DEST_ROOT/$WORLD" ]; then
        # year folder doesn't exist, we need to create that first
        mkdir $DEST_ROOT/$WORLD/$YEAR
        # then create the month folder using the destination path
        mkdir $DEST

elif [ -d "$DEST_ROOT" ]; then
        # world dirs don't exist, we need to create those first
        mkdir $DEST_ROOT/$WORLD
        # then year
        mkdir $DEST_ROOT/$WORLD/$YEAR
        # then finally the entire destination
        mkdir $DEST
else
        echo "(worker) BACKUP: Backup destination cannot be created. Backup failed."
        echo "(worker) BACKUP: Intended destination was $DEST"
        exit 2
fi



# create the temp directories
mkdir $TMP
mkdir $TMP/$BACKUP

# copy source to temp diri
echo "(worker) BACKUP: Copying files to temp directory..."
cp -r $SOURCE $TMP/$BACKUP/$WORLD
cp -r ${SOURCE}_nether $TMP/$BACKUP/${WORLD}_nether
cp -r $SOURCE $TMP/$BACKUP/${WORLD}_the_end

# compress the backup
echo "(worker) BACKUP: Compressing files..."
tar -czf $TMP/$BACKUP.tar.gz $TMP/$BACKUP >/dev/null 2>/dev/null

# copy the backup to the destination
echo "(worker) BACKUP: Copying files to backup directory..."
cp $TMP/$BACKUP.tar.gz $DEST/

# clean up the temp directory
rm -rf $TMP



echo "(worker) BACKUP: Backup complete."