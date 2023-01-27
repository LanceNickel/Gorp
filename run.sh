#!/usr/bin/env bash

# THIS IS THE IN-SERVER-DIRECTORY RUN SCRIPT
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# None



# ==== CHANGE JAR ====
# Change the value below to a custom absolute path to the JAR file for this server.
# This is an advanced setting and is not supported, as it may break your install.
# Please be sure to use a Paper server or properly migrate this server away from Paper if it was initially created with paper.
# Also, please accept the risk of manual updates or running outdated server software.
# Default: JAR=$(cat /minecraft/jars/latest)

JAR=$(cat /minecraft/jars/latest)

## END OF OPTIONS
# Please don't edit below this line







RAM=$(cat /minecraft/cum.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)




while [ true ]; do
        java -Xmx$RAM -Xms$RAM -jar $JAR nogui

        echo "\n\n THIS SERVER HAS STOPPED! Press any key to prevent restart."

        read -t 5 input;

        if [ $? == 0 ]; then
                break;
        else
                echo "Restarting server..."
        fi
done