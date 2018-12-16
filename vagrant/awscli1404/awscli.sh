#!/bin/bash

sudo apt-get update -y
sudo apt-get install build-essential -y

# decide python version, python3 if xenial or newer
if [ `lsb_release -cs` == trusty ]; then
 PVER=""
else
 PVER="3"
fi

# start in home directory
cd ~

sudo apt-get install python${PVER}  python${PVER}-dev python${PVER}-pip -y
echo ===PYTHON=====================================
python${PVER} --version

echo ==PIP======================================
pip${PVER} --version
sudo -H pip${PVER} install --upgrade pip
pip${PVER} --version

# ignore InsecurePlatformWarning from urllib3 on Ubuntu trusty
echo ==VENV1======================================
sudo -H pip${PVER} install virtualenv
virtualenv --version

echo ==VENV2======================================
pip${PVER} install virtualenv --upgrade
virtualenv --version

# create virtual environment for awscli
virtualenv awscli
source awscli/bin/activate

# now inside virtualenv
pip${PVER} install --upgrade awscli
aws --version


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
  AWS_FORMAT="table"
fi
echo ==ENV======================================
echo AWS_ACCESS_KEY_ID is $AWS_ACCESS_KEY_ID
echo Using AWS REGION/FORMAT: $AWS_REGION $AWS_FORMAT

# write config and credentials to files
mkdir .aws
cat >.aws/credentials <<EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

cat >.aws/config <<EOL
[default]
region = ${AWS_REGION}
output = ${AWS_FORMAT}
EOL

# set permissions
chmod 600 .aws/credentials
chmod 600 .aws/config



