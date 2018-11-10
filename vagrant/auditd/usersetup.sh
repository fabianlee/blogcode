#!/bin/bash

# create alice user
sudo useradd -u 20001 -m alice

# set static password and ensure group definition added to /etc/group
phash=$(openssl passwd -1 -salt mysalt alicepass)
sudo usermod -a -G deployers -p "$phash" alice

# alice gets full sudo privileges
echo "alice ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/alice

# create script that developers can use in sudo
cat >/tmp/quicktest.sh <<'EOL'
#!/bin/bash
echo "$0 invoked as user '${SUDO_USER}' which is member of groups:"
groups
echo "script being run as user id $EUID"
if [[ $EUID -ne 0 ]] ; then echo "UNEXPECTED!!! this script was expectd to be run as root/sudo" ; exit 1 ; fi
grep alice /etc/shadow
EOL

# owned by root but executable by all
sudo chown root:root /tmp/quicktest.sh
sudo chmod ugo+r+x /tmp/quicktest.sh

