#!/bin/bash

sudo apt-get update
sudo apt-get install python-gnupg rng-tools -y
sudo rngd -r /dev/urandom

# create groups
# 'deployers' ability to decrypt production secrets for operational tasks
# 'developers' no ability to decrypt production secrets
sudo groupadd -g 11000 deployers
sudo groupadd -g 11001 developers

# make 2 users part of 'deployers' group, should be able to decrypt and sudo
sudo useradd -u 20001 -g deployers -m alice
sudo useradd -u 20002 -g deployers -m bob

# set static password and ensure group definition added to /etc/group
phash=$(openssl passwd -1 -salt mysalt alicepass)
sudo usermod -a -G deployers -p "$phash" alice
phash=$(openssl passwd -1 -salt mysalt bobpass)
sudo usermod -a -G deployers -p "$phash" bob

# make 1 user part of 'developers' group, should not be able to decrypt or sudo
sudo useradd -u 20003 -g developers -m billy
phash=$(openssl passwd -1 -salt mysalt billypass)
sudo usermod -a -G developers -p "$phash" billy

# deployers group gets full sudo privileges
echo "%deployers ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/deployers

# developers group gets access to single shell script
echo "%developers ALL=(ALL) /tmp/developersDecrypt.sh" | sudo tee /etc/sudoers.d/developers
