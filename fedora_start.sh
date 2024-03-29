#! /usr/bin/bash
echo "Starting the script with user: $USER and sudo user: $SUDO_USER"

echo "Updating the system..."
sudo dnf update -y

# install nodejs and  npm
echo "Installing Node.js and npm..."
sudo dnf install nodejs npm -y

#ask to install java 17 or latest java
read -p "Would you like to install Java 17? (y/N): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    echo "Installing Java 17..."
    sudo dnf install java-17-openjdk -y
else
    echo "Installing the latest version of Java..."
    sudo dnf install java-latest-openjdk -y
fi
# set java home
# Find the path to the Java executable
JAVA_PATH=$(readlink -f $(which java))

# Derive the JAVA_HOME from JAVA_PATH, assuming the path ends with /bin/java
JAVA_HOME="${JAVA_PATH%/bin/java}"

# Find the path to the Java executable
JAVA_PATH=$(readlink -f $(which java))

# Derive the JAVA_HOME from JAVA_PATH, assuming the path ends with /bin/java
JAVA_HOME="${JAVA_PATH%/bin/java}"

# Check if JAVA_HOME is valid
if [[ -d "$JAVA_HOME" ]]; then
    echo "Setting JAVA_HOME to $JAVA_HOME"
    export JAVA_HOME="$JAVA_HOME"
    echo "JAVA_HOME is set to $JAVA_HOME"
else
    echo "Java installation could not be found."
fi

# install JetBrains Toolbox
if ! command -v jetbrains-toolbox &> /dev/null
then
    echo "Installing JetBrains Toolbox..."
    wget -O jetbrains-toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
    sudo tar -xzf jetbrains-toolbox.tar.gz -C /opt/
    rm jetbrains-toolbox.tar.gz
fi
#isntall Maven
if ! command -v mvn &> /dev/null
then
    echo "Installing Maven..."
    sudo dnf install maven -y
fi
#install vscode
if ! command -v code &> /dev/null
then
    echo "Installing VS Code..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf check-update
    sudo dnf -y install code # or code-insiders
fi

#install docker engine
if ! command -v docker &> /dev/null
then
    echo "Installing Docker Engine..."
    sudo dnf -y remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
# linux post install docker
    echo "Attempting to add user to docker group..."
    sudo usermod -aG docker $SUDO_USER
    sudo systemctl enable docker
fi

echo "Installation complete. A reboot is required for Docker group changes to take effect."
read -p "Would you like to reboot now? (y/N): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Please remember to reboot your system later to apply all changes."
fi
