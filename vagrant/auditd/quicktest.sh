#!/bin/bash
echo "$0 invoked as user '${SUDO_USER}' which is member of groups:"
groups
echo "script being run as user id $EUID"
if [[ $EUID -ne 0 ]] ; then echo "UNEXPECTED!!! this script was expectd to be run as root/sudo" ; exit 1 ; fi
grep alice /etc/shadow
