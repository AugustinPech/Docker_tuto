#!/usr/bin/env bash
# make sure your machine is up to date
sudo apt udate & sudo apt upgrade
# install prerequisites
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release -y
# add GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add docker repo to apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# make sure your machine is up to date
sudo apt update & sudo apt upgrade
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt-get update && sudo apt-get install -y apparmor
# make sure you are about to install from the Docker repo instead of the default Ubuntu repo:
test=$(apt-cache policy docker-ce | grep "500")
if [ "$test" -eq 0 ]; then
  echo "Docker is not available in the default Ubuntu repo. Please check the Docker repo has been added correctly."
  exit 1
fi
	
# proper install
sudo apt install docker.io -y

sudo usermod -aG docker "$USER"