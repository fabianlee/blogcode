#!/bin/bash
# invokes local playbook that exercises Ansible lineinfile

# reset file and show contents
cp my.yml.bak my.yml
echo "***ORIGINAL*******************************"
cat my.yml
echo "******************************************"


# run transformation
ansible-playbook --connection=local --inventory 127.0.0.1 test-lineinfile.yml


# show results and then reset file
echo "***UPDATED********************************"
cat my.yml
echo "******************************************"
cp my.yml.bak my.yml
