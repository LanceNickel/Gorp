#!/usr/bin/env bash

### [GORP ENTRY POINT] ############################################
#   Description:  The Gorp entry-point file. Set's up execution.
#   Parameters:   1: (required) Action to pass to arg-int.
#                 2: (optional) Argument 1
#                 3: (optional) Argument 2

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>







################ SETUP ################







######## ERROR HANDLER

handle_error() {
    message=$1

    if [[ "$1" == "" ]]; then
        message="ERROR: Gorp encountered an error and exited. Furthermore, no internal error message was provided."
    fi

    echo "ERROR: $message"

    exit 1
}



######## No root/sudo.

if [[ "$EUID" == 0 ]]; then
    handle_error "Gorp cannot be run as root or with sudo."
fi



######## Get parameters.

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh || handle_error "Unable to load Gorp parameters."



######## Create tmp directory

mkdir -p /tmp/gorp/ || handle_error "Unable to create tmp directory at /tmp/gorp/"



######## Handle lock file.

if [[ -f "/tmp/gorp/gorp.lock" ]]; then
    handle_error "Gorp is already running."
else
    touch /tmp/gorp/gorp.lock || handle_error "Unable to create lock file."
fi







################ EXECUTE ################







source /usr/local/bin/gorpmc/argparse.sh $1 $2 $3







################ CLEAN UP ################







####### Delete tmp dir.

rm -rf /tmp/gorp/ || handle_error "Unable to delete tmp directory at /tmp/gorp/"



####### Release lock file

rm /tmp/gorp/gorp.lock







################ EXIT ################







######## We made it!

exit 0