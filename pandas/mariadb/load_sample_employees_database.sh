#!/bin/bash
#
# Load Employees sample database into MariaDB
#

echo "Loading example Employees database from ~/Downloads/test_db"

pushd . > /dev/null
cd ~/Downloads
[ -d "test_db" ] || { echo "ERROR could not find ~/Downloads/test_db, have you run 'fetch_sample_employees_database.sh'?"; exit 3; }

cd test_db

path=$(which mysql)
[ -n "$path" ] || { echo "ERROR could not find mysql client binary. Use: sudo apt install mariadb-client"; exit 3; }

export dbIP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadbtest)
[ -n "$dbIP" ] || { echo "ERROR could not find MariaDB docker image named 'mariadbtest'"; exit 3; }
echo "MariaDB listening on $dbIP:3306"

mysql_prefix="mysql -h $dbIP -u root -pthepassword"
if $mysql_prefix -e "show databases;" | grep -q "employees"; then
  echo "employees database already exists"
else
  echo "need to create employees database"
  $mysql_prefix -e "create database employees;"
  echo ""
  echo "need to load employees data"
  $mysql_prefix -D employees < employees.sql
fi

popd > /dev/null
