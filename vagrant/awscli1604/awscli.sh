#!/bin/bash

# start in home directory
cd ~

sudo apt-get update -yq
sudo apt-get install build-essential -yq

# decide python version, python3 if xenial or newer
if [ `lsb_release -cs` == trusty ]; then
 PVER=""
else
 PVER="3"
fi

sudo apt-get install python${PVER}  python${PVER}-dev python${PVER}-pip -yq
echo ===PYTHON=====================================
python${PVER} --version

echo ==PIP======================================
pip${PVER} --version
sudo -H pip${PVER} install --upgrade pip
pip --version

echo ==VENV1======================================
sudo -H pip install virtualenv
virtualenv --version

echo ==VENV2======================================
pip install virtualenv --upgrade
virtualenv --version

# create virtual environment for awscli
virtualenv awscli
source awscli/bin/activate

# install awscli inside virtualenv
pip install --upgrade awscli
aws --version

# exit virtualenv
deactivate


# if ENV vars not set for these values, then assign defaults
if [ -z $AWS_ACCESS_KEY_ID ]; then
  AWS_ACCESS_KEY_ID="na"
fi
if [ -z $AWS_SECRET_ACCESS_KEY ]; then
  AWS_SECRET_ACCESS_KEY="myP4ss!"
fi
if [ -z $AWS_REGION ]; then
  AWS_REGION="us-east-1"
fi
if [ -z $AWS_FORMAT ]; then
  AWS_FORMAT="json"
fi
echo ==ENV======================================
echo AWS_ACCESS_KEY_ID is $AWS_ACCESS_KEY_ID
echo Using AWS REGION/FORMAT: $AWS_REGION/$AWS_FORMAT

# write credentials file
mkdir .aws
cat >.aws/credentials <<EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

# write config file 
cat >.aws/config <<EOL
[default]
region = ${AWS_REGION}
output = ${AWS_FORMAT}
EOL

# write AWS vars to profile
echo export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID >> ~/.bash_profile
echo export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" >> ~/.bash_profile
echo export AWS_REGION=$AWS_REGION >> ~/.bash_profile

# set permissions for config/credentials
chmod 600 .aws/credentials
chmod 600 .aws/config


