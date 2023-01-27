#!/usr/bin/env bash

# THIS IS THE IN-SERVER-DIRECTORY RUN SCRIPT
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# None

# SETTINGS:

# JAR
# JAR file to use for the server (PAPER REQUIRED!)
# Default: JAR=$(cat /minecraft/jars/latest)
JAR=$(cat /minecraft/jars/latest)

# MIN and MAX
# Use these to allocate memory to the server, both should have the same valye.
# Enter in terms of gigabytes.
# Default: MAX=10G, MIN=10G
MAX=10G
MIN=10G







while [ true ]; do
        java -Xmx$MAX -Xms$MIN -jar $JAR nogui

        echo "\n\n THIS SERVER HAS STOPPED! Press any key to prevent restart."

        read -t 5 input;

        if [ $? == 0 ]; then
                break;
        else
                echo "Restarting server..."
        fi
done