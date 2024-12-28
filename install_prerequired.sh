#!/bin/bash

# エラー発生時にスクリプトを停止
set -e

# Resolve potential NVIDIA repository issues (only remove if the file exists)
[ -f /etc/apt/sources.list.d/nvidia-container-toolkit.list ] && sudo rm /etc/apt/sources.list.d/nvidia-container-toolkit.list
[ -f /etc/apt/sources.list.d/nvidia-docker.list ] && sudo rm /etc/apt/sources.list.d/nvidia-docker.list

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
codename=$(grep UBUNTU_CODENAME /etc/os-release | cut -d= -f2)

# Install Docker
echo "Installing docker-ce"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# Add Docker's official GPG key and store it in a dedicated keyring
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Manually add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $codename stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce
echo ""

# Install NVIDIA Docker 2
echo "Installing nvidia-docker2"
curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-docker-keyring.gpg
# Add the NVIDIA Docker repository using the keyring
curl -fsSL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-docker-keyring.gpg] https://#' | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
echo ""