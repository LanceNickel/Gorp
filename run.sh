#!/usr/bin/env bash

### [RUN SERVER IN-DIRECTORY WORKER] ##############################
#   Description:  Worker that actually executes a server JAR.
#   Parameters:   None
#   Global Conf:  RAM

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################
# DO NOT, EVER, EVER, EVER, EVER CHANGE THE RUN SCRIPT VERSION NUMBER BELOW!
RUN_VER=2



# ==== CHANGE JAR ====
# Change the value below to a custom absolute path to the JAR file for this server.
# This is an advanced setting and is not supported, as it may break your install.
# Please be sure to use a Paper server or properly migrate this server away from Paper if it was initially created with paper.
# Also, please accept the risk of manual updates or running outdated server software.
# Default: JAR=$(cat /minecraft/jars/latest)

JAR=$(cat /minecraft/jars/latest)

## END OF OPTIONS
# Please don't edit below this line




# SCRIPT VARIABLES

RAM=$(cat /minecraft/cum.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)



####



# EXECUTE SERVER, WAIT FOR PROCESS TO DIE

while [ true ]; do
        java -Xmx$RAM -Xms$RAM -jar $JAR nogui

        echo -e "\n\nTHIS SERVER HAS STOPPED! Press any key to prevent restart."

        read -t 5 input;

        if [ $? == 0 ]; then
                break;
        else
                echo "Restarting server..."
        fi
done