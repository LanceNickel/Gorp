#!/usr/bin/env bash

### [PARAMETERS] ##################################################
#   Description: Scripts/callable functions to handle params.

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>







#### GORP VERSION

GORP_VERSION="0.8.1"



#### HOMEDIR (only config item set DIRECTLY within this file)

HOMEDIR=



#### CONFIG FILE GUARD

if [[ ! -f "$HOMEDIR"/gorp.conf ]]; then
    handle_error "(params) Configuration file not found."
fi



#### GET CONFIG FILE ITEMS

GAMEVER="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
RAM="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep -e '^RAM=' | cut -d '=' -f2)"
MAX_RAM="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'MAX_RAM=' | cut -d '=' -f2)"
BACKUP_DEST="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)"
ARCHIVE_DEST="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)"
UPDATE_FREQUENCY="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'UPDATE_FREQUENCY=' | cut -d '=' -f2)"
TEXT_EDITOR="$(cat "$HOMEDIR"/gorp.conf | grep "^[^#;]" | grep 'TEXT_EDITOR=' | cut -d '=' -f2)"



#### GET LATEST JAR

LATEST_JAR="$(cat $HOMEDIR/jars/latest)"







#### MAKE SURE ALL ARE POPULATED

if [[ "$GAMEVER" == "" ]] || [[ "$RAM" == "" ]] || [[ "$HOMEDIR" == "" ]] || [[ "$BACKUP_DEST" == "" ]] || [[ "$ARCHIVE_DEST" == "" ]] || [[ "$LATEST_JAR" == "" ]]; then
    handle_error "(params) One or more required options in gorp.conf not set."
fi
