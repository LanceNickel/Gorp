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
3. Make a new folder called install: `mkdir install && cd install`
4. Run `git clone https://github.com/LanceNickel/mc-cum/ && cd mc-cum`
5. Run `chmod +x install.sh`
6. Run `sudo ./install.sh`
