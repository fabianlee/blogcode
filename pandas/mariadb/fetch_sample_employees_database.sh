#!/bin/bash
#
# Download Employees sample database for loading into MariaDB
#

echo "Fetching example Employees database to ~/Downloads/test_db"

pushd . > /dev/null
cd ~/Downloads

# download and unzip
if [ ! -f test_db-1.0.7.tar.gz ]; then
  wget https://github.com/datacharmer/test_db/releases/download/v1.0.7/test_db-1.0.7.tar.gz
else
  echo "test datbase archive already downloaded"
fi
if [ ! -d test_db ]; then
  tar xvfz test_db-1.0.7.tar.gz
else
  echo "test database already unarchived"
fi

cd test_db
ls -l *.sql


popd > /dev/null
