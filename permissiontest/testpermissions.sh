#!/bin/bash
#
# Script for creating a directory named 'testp'
# with various levels of ownership, permissions, modification dates
# used to test preservation abilities of cp, rsync, tarA
#


function createUsersGroups() {
 sudo groupadd -g 10001 toons
 sudo groupadd -g 10002 people
 sudo useradd -u 10500 -g toons bugs
 sudo useradd -u 10501 -g toons daffy
 sudo useradd -u 10502 -g people michael
 sudo usermod -g toons bugs
 sudo usermod -g toons daffy
 sudo usermod -g people michael
}

function createDirs() {
 mkdir testp
 sudo mkdir testp/for-toons
 sudo mkdir testp/for-toons/for-bugs
 sudo mkdir testp/for-people

 sudo chown bugs:toons testp/for-toons
 sudo chown bugs:toons testp/for-toons/for-bugs
 sudo chown michael:people testp/for-people
 sudo chown michael:people testp/for-people

 sudo chmod 770 testp/for-toons
 sudo chmod 700 testp/for-toons/for-bugs
 sudo chmod 770 testp/for-people
}

function createContent() {
 cd testp

 echo "this is for all" | sudo tee forall.txt
 sudo chmod ugo+r+w forall.txt

 echo "this is writable by people, readable by toons" | sudo tee peoplewrite-toonsread.txt
 sudo chown michael:toons peoplewrite-toonsread.txt
 sudo chmod 772 peoplewrite-toonsread.txt

 echo "rw by toons" | sudo tee for-toons/rw-by-toons.txt
 echo "only for bugs" | sudo tee for-toons/for-bugs/only-for-bugs.txt
 sudo chown -R bugs:toons for-toons
 sudo chmod 770 for-toons/*.txt
 sudo chmod -R 700 for-toons/for-bugs/*.txt

 sudo echo "this is only for people" | sudo tee for-people/rw-for-people.txt
 sudo chmod 770 for-people/rw-for-people.txt

 cd ..
}

function setModifiedDates() {
 find testp/*.txt -type f -exec touch -a -m -t 201801012300 {} \;
 find testp/for-toons/* -name *.txt -type f -exec touch -a -m -t 199912252300 {} \;
 find testp/for-people/* -name *.txt -type f -exec touch -a -m -t 200106062300 {} \;
}

###### MAIN ###########

createUsersGroups
createDirs
createContent
setModifiedDates



