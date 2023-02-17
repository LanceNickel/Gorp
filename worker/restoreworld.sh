#!/usr/bin/env bash

### [WORLD RESTORE WORKER] ########################################
#   Description:  Worker script that performs world restore tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "restoreworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
BACKUP_DIR=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'BACKUPS=' | cut -d '=' -f 2)

CURRENT_LEVEL_NAME=$(cat /minecraft/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)



####



# SELECT FROM AVAILABLE WORLD FILES

cd $BACKUP_DIR/$SERVER

echo -e "\nPlease select a world (level-name in server.properties)"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d"
RESTORE_LEVEL_NAME=$d



# SELECT FROM AVAILABLE YEARS

echo -e "\nSelect year"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d"
YEAR=$d



# SELECT FROM AVAILABLE MONTHS

echo -e "\nSelect month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d"
MONTH=$d



# SELECT FROM AVAILABLE DAYS

echo -e "\nSelect day of month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d"
DAY=$d



# SELECT BACKUP FILE

echo -e "\nSelect backup to restore from\nDate format is YYYY-MM-DD_HHMM-SS"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

FILE_TO_RESTORE="$d"
FOLDER_TO_RESTORE=$(echo $d | cut -d '.' -f1)



# BACKUP CURRENT WORLD

echo "restoreworld.sh: Backing up current world..."

sleep 0.5

/usr/local/bin/gorputils/action/mcbackupworld $SERVER



# FLUSH CURRENT WORLD

echo "restoreworld.sh: Restoring selected files..."

rm -rf /minecraft/servers/$SERVER/${CURRENT_LEVEL_NAME}*



# RESTORE WORLD

rm -rf /minecraft/tmp
mkdir -p /minecraft/tmp/restore

cp $BACKUP_DIR/$SERVER/$RESTORE_LEVEL_NAME/$YEAR/$MONTH/$DAY/$FILE_TO_RESTORE /minecraft/tmp/restore/

tar -xf /minecraft/tmp/restore/$FILE_TO_RESTORE -C /minecraft/tmp/restore/

cp -r /minecraft/tmp/restore/$FOLDER_TO_RESTORE/* /minecraft/servers/$SERVER/



echo "restoreworld.sh: Restoration complete."