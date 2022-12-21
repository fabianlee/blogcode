#!/bin/bash

sudo snap install yq
yq --version

exit 0

#
# manual steps for installing yq below
#

sudo apt get install curl jq wget -y

# get latest release version
latest_yq_linux=$(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r ".assets[].browser_download_url" | grep linux_amd64.tar.gz)

# download, extract, and put binary into PATH
wget $latest_yq_linux
tar xvfz yq_linux_amd64.tar.gz
sudo cp yq_linux_amd64 /usr/local/bin/yq
