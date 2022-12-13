#!/bin/bash
#
# Install 'lab' GitLab CLI
# https://github.com/zaquestion/lab
#

latest="$(curl -sL 'https://api.github.com/repos/zaquestion/lab/releases/latest' | grep 'tag_name' | grep -o 'v[0-9\.]\+' | cut -c 2-)"
echo "latest=$latest"

[ -f /tmp/lab.tar.gz ] || wget "https://github.com/zaquestion/lab/releases/download/v${latest}/lab_${latest}_linux_amd64.tar.gz" -O /tmp/lab.tar.gz

# place binary in current directory, then move to PATH
tar xvfz /tmp/lab.tar.gz lab
sudo chown root:root lab
sudo mv lab /usr/local/bin/.

which lab
lab --version

echo "Run 'lab' to create config ~/.config/lab/lab.toml"

