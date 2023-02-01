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
RUN_VER=3



# ==== CHANGE JAR ====
# Further documentation: https://github.com/LanceNickel/mc-cum/wiki/Changing-Individual-Server-Settings
# Change the value below to a custom absolute path to the JAR file for this server.
# This is an advanced setting and is not supported, as it may break your install.
# Please be sure to use a Paper server or properly migrate this server away from Paper if it was initially created with paper.
# Also, please accept the risk of manual updates or running outdated server software.
# Default: JAR=$(cat /minecraft/jars/latest)

JAR=$(cat /minecraft/jars/latest)



# ==== CHANGE RAM =====
# Further documentation: https://github.com/LanceNickel/mc-cum/wiki/Changing-Individual-Server-Settings
# Change this value to change the amount of RAM (in gigabytes) to be allocated for this server instance.
# Plese change it based on what you believe will be required.
# This is a good resource: https://minecraft.fandom.com/wiki/Server/Requirements/Dedicated#Unix_(Linux,_BSD,_macOS)
# Default: RAM=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)

RAM=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)



#### END OF OPTIONS! Please do not edit below this line.



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
