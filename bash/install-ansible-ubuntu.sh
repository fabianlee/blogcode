#!/bin/bash


sudo apt-get update
sudo apt-get install software-properties-common -y
sudo -E apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y

# quick ansible config
cat << EOF > ansible.cfg
[defaults]
inventory = ansible-hosts
host_key_checking = False
EOF

cat << EOF > ansible-hosts
# aliases
myhost ansible_host=127.0.0.1

[my_group]
myhost ansible_user=$(whoami)
#myhost ansible_user=ubuntu ansible_password=xxxx ansible_become_pass=xxxxx

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

mkdir -p host_vars
cat << EOF > host_vars/myhost
myhostval1: one
myhostval2: two
host_myuser: World
EOF

cat << EOF > ansible-ping-playbook.yaml
---
- hosts: all
  gather_facts: false
  vars:
    playbook_myuser: Foo
  vars_prompt:
  - name: ansible_ssh_pass
    prompt: "For the localhost test, what is the password for user $(whoami) ?"
    private: no
  tasks:
  - name: do ping
    action: ping
  - name: show variable
    debug:
      msg: hello, I'm pulling {{host_myuser}} from host level variables, and {{playbook_myuser}} from playbook level variables
EOF

touch run-ansible-playbook.sh
chmod +x run-ansible-playbook.sh
cat << EOF > run-ansible-playbook.sh
ansible-playbook ansible-ping-playbook.yaml -v
EOF

touch run-ansible-ping.sh
chmod +x run-ansible-ping.sh
cat << EOF > run-ansible-ping.sh
ansible -m ping all
EOF

echo ""
echo ""
echo "Modify 'ansible-hosts' with a proper remote host and credentials, then run:"
echo "./run-ansible-ping.sh"
echo "./run-ansible-playbook.sh"
