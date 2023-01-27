## Requirements
* At least 8GB RAM (for decent Minecraft server performance)
* At least 120GB storage (for world saves and local backups)
* Debian or Debian-based distro (Tested on: Debian 11, Ubuntu Server 20.04 LTS, Mint 21.1)


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

### Initial server setup
1. Go to the default Minecraft server directory: `cd /minecraft/servers/server`
2. Execute run.sh: `sudo ./run.sh`
3. The server will show errors. This is normal! Wait for the "THIS SERVER HAS STOPPED! warning, then press any key.
4. Read and accept the EULA: `sudo nano eula.txt`
5. Change `eula=false` to `eula=true`
6. Press `CTL + X`, `Y`, `ENTER` to save and quit the text editor.
7. Now, start the server with `sudo mcstart server`

### Wrapping up
Congratulations! You have now installed the C.U.M. and started up your Minecraft server.

## Next steps
Customize your server.properties file to change the settings you want. [Learn more about server.properties](https://minecraft.fandom.com/wiki/Server.properties).

Learn more about the C.U.M. on the [Getting Started wiki page](https://github.com/LanceNickel/mc-cum/wiki/Getting-Started).
