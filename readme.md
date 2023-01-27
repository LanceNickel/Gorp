# The C.U.M. (Commandline Utility Mechanism)
Hello! I created this small jumble of shell scripts to help automate my Minecraft server and thought I'd polish it a bit and put it here. It is by no means the most advanced Minecraft utility, and it could probably be written better. However, it is very simple to install, update, and uninstall.

Below are the requirements and installation instructions for this software. It will take you from no Minecraft (not even a JAR file) to an online server.




## Requirements
* At least 8GB RAM (for decent Minecraft server performance)
* At least 120GB storage (for world saves and local backups)
* Debian or Debian-based distro (Tested on: Debian 11, Ubuntu Server 20.04 LTS, Mint 21.1)




## Notices
The C.U.M. will update or install the following packages and their dependencies:
* apt-transport-https
* curl
* wget
* jq
* screen




## Installation instructions

### Install Java 17
1. Run `sudo apt update`
2. Run `sudo apt install openjdk-17-jdk openjdk-17-jre`
3. Run `java --version`
You should see something like:
```
openjdk 17.0.5 2022-10-18
OpenJDK Runtime Environment (build 17.0.5+8-Ubuntu-2ubuntu122.04)
OpenJDK 64-Bit Server VM (build 17.0.5+8-Ubuntu-2ubuntu122.04, mixed mode, sharing)
```


### Download and install the C.U.M.
1. SSH into your (soon to be) Minecraft server.
2. Go to your home directory: `cd`
3. Run `git clone https://github.com/LanceNickel/mc-cum/ && cd mc-cum`
4. Run `chmod +x install.sh`
5. Run `sudo ./install.sh`

The C.U.M. has been installed and a basic server has been created.

#### HEADS UP: If you received a warning message:
If you received a warning message about the `/minecraft` directory already existing, please read this.

During install, the installer script noticed that your computer already has a directory named "minecraft" in the root. Because this could be from a previous install of this utility, or previous use, the installer skips these directories. This is to prevent potential catastrophic data loss.


### Initial server setup
1. Go to the default Minecraft server directory: `cd /minecraft/servers/server`
2. Execute run.sh: `sudo ./run.sh`
3. The server will show errors. This is normal! Wait for the stop warning, then press any key to quit.
4. Read and accept the EULA: `sudo nano eula.txt`
5. Change `eula=false` to `eula=true`
6. Press `CTL + X`, `Y`, `ENTER` to save and quit the text editor.
7. Now, start the server with `sudo mcstart server`


### Wrapping up
Congratulations! You have now installed the C.U.M. and started up your Minecraft server.




## Next steps
Customize your server.properties file to change the settings you want. [Learn more about server.properties](https://minecraft.fandom.com/wiki/Server.properties).

Learn more about the C.U.M. on the [Getting Started wiki page](https://github.com/LanceNickel/mc-cum/wiki/Getting-Started).
