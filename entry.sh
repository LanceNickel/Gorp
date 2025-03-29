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

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ############

. /usr/local/bin/gorpmc/functions/exit.sh
. /usr/local/bin/gorpmc/functions/params.sh
. /usr/local/bin/gorpmc/functions/functions.sh







#### SETUP ############

ACTION="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"



#### No root/sudo.

if [[ "$EUID" == 0 ]]; then
    handle_error "Gorp cannot be run as root or with sudo."
fi



#### Create tmp directory

mkdir -p /tmp/gorp/ || handle_error "Unable to create tmp directory at /tmp/gorp/"



#### Handle lock file.

if [[ -f "/tmp/gorp/gorp.lock" ]]; then
    handle_error "Gorp is already running."
else
    touch /tmp/gorp/gorp.lock || handle_error "Unable to create lock file."
fi







#### EXECUTE ############

bash /usr/local/bin/gorpmc/argparse.sh "$ACTION" "$ARG1" "$ARG2" "$ARG3"







#### CLEAN UP ############

#### Delete tmp dir (by extension, releasing lock)

rm -rf /tmp/gorp/ || handle_error "Unable to delete tmp directory at /tmp/gorp/"







#### WE MADE IT ############

exit 0