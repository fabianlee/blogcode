#!/bin/bash

sudo apt-get update -q
sudo ufw allow 3142/tcp
sudo apt-get install apt-cacher-ng -y
echo "PassThroughPattern: .*" | sudo tee -a /etc/apt-cacher-ng/acng.conf
echo "VerboseLog: 2" | sudo tee -a /etc/apt-cacher-ng/acng.conf
sudo ufw allow 3142/tcp
