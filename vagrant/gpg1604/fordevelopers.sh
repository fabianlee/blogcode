#!/bin/bash

# create script that developers can use in sudo
cat >/tmp/developersDecrypt.sh <<'EOL'
#!/bin/bash
echo "$0 invoked as user '${USER}' which is member of groups:"
groups
echo "script being run as user id $EUID"
if [[ $EUID -ne 0 ]] ; then echo "EXPECT ERROR!!! this script must be run as root/sudo" ; exit 1 ; fi
gpg --homedir /etc/deployerkeys --list-keys
echo "NOTE: This decrypted secret would normally be silently passed to another process, and not ever shown or available to the user. But for purposes of example, here it is:"
gpg --homedir /etc/deployerkeys -qd /tmp/test.crypt
echo
EOL

# owned by root but executable by all
sudo chown root:root /tmp/developersDecrypt.sh
sudo chmod ugo+r+x /tmp/developersDecrypt.sh

# now create another script that 'developers' cannot execute via sudo
sudo cp /tmp/developersDecrypt.sh /tmp/developersNotAllowed.sh

