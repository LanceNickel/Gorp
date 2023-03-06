#!/usr/bin/env bash

### [SERVER RESTORE WORKER] #######################################
#   Description:  Worker script that performs server restore tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "restoreserver.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2







####







### SELECT FROM AVAILABLE WORLD FILES

cd $BACKUP_DEST/$SERVER/server-backups







### SELECT FROM AVAILABLE YEARS

echo -e "\nSelect year"

select d in *;
do
    test -n "$d" && break
    if $OUTPUT; then echo ">>> Invalid selection"; fi
done

cd "$d"
YEAR=$d







### SELECT FROM AVAILABLE MONTHS

echo -e "\nSelect month"

select d in *;
do
    test -n "$d" && break
    if $OUTPUT; then echo ">>> Invalid selection"; fi
done

cd "$d"
MONTH=$d







### SELECT FROM AVAILABLE DAYS

echo -e "\nSelect day of month"

select d in *;
do
    test -n "$d" && break
    if $OUTPUT; then echo ">>> Invalid selection"; fi
done

cd "$d"
DAY=$d







### SELECT BACKUP FILE

echo -e "\nSelect backup to restore from\nDate format is YYYY-MM-DD_HHMM-SS"

select d in *;
do
    test -n "$d" && break
    if $OUTPUT; then echo ">>> Invalid selection"; fi
done

FILE_TO_RESTORE="$d"
FOLDER_TO_RESTORE=$(echo $d | cut -d '.' -f1)







### BACKUP CURRENT WORLD

if $OUTPUT; then echo "Backing up current server..."; fi

/usr/local/bin/gorpmc/action/mcbackupserver $1 $SERVER



### FLUSH CURRENT SERVER

if $OUTPUT; then echo "Restoring selected files..."; fi

rm -rf $HOMEDIR/servers/$SERVER/







### RESTORE WORLD

rm -rf $HOMEDIR/tmp
mkdir -p $HOMEDIR/tmp/restore

cp $BACKUP_DEST/$SERVER/server-backups/$YEAR/$MONTH/$DAY/$FILE_TO_RESTORE $HOMEDIR/tmp/restore/

tar -xf $HOMEDIR/tmp/restore/$FILE_TO_RESTORE -C $HOMEDIR/tmp/restore/

cp -r $HOMEDIR/tmp/restore/$FOLDER_TO_RESTORE/* $HOMEDIR/servers/







if $OUTPUT; then echo "Server restored from backup!"; fi