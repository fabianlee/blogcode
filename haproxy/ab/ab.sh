sudo apt-get update -q

cd /usr/src
wget http://apache.mirrors.pair.com/httpd/httpd-2.4.28.tar.gz
tar xfz httpd-2.4.28.tar.gz
cd httpd-2.4.28

cp support/ab.c support/ab.c.old
wget https://raw.githubusercontent.com/fabianlee/blogcode/master/haproxy/ab.c -O support/ab.c

sudo apt-get install libapr1-dev libaprutil1-dev libpcre3 libpcre3-dev -y
./configure
make

support/ab -V

sudo cp support/ab /usr/sbin/ab

ab -V
