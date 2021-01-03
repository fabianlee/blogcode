#!/bin/bash
# invokes local playbook that exercises Ansible lineinfile

echo "***ORIGINAL*******************************"
cat test.cfg
echo "******************************************"


# run transformation
ansible-playbook --connection=local --inventory 127.0.0.1 test-lineinfile.yml


# show results and then reset file
echo "***UPDATED********************************"
cat test.cfg
echo "******************************************"
cp test.cfg.bak test.cfg
