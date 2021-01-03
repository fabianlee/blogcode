#!/bin/bash
# invokes local playbook that exercises Ansible lineinfile

# reset file and show contents
cp key-value.cfg.bak key-value.cfg
echo "***ORIGINAL*******************************"
cat key-value.cfg
echo "******************************************"


# run transformation
ansible-playbook --connection=local --inventory 127.0.0.1 test-lineinfile.yml


# show results and then reset file
echo "***UPDATED********************************"
cat key-value.cfg
echo "******************************************"
cp key-value.cfg.bak key-value.cfg
