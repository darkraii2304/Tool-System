#!/bin/bash

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove $pkg -y
    done

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg	
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Function to install Docker on CentOS
install_docker_centos() {
    sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y

    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
}

# Function to install Portainer CE
install_portainer() {
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
}

# Check the Linux distribution
distro=$(lsb_release -i | awk '{print $3}')

if [[ "$distro" == "Ubuntu" ]]; then
    install_docker_ubuntu
elif [[ "$distro" == "CentOS" ]]; then
    install_docker_centos
else
    echo "Unsupported Linux distribution. Please use Ubuntu or CentOS."
    exit 1
fi

install_portainer

