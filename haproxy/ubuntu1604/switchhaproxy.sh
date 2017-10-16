#!/bin/bash 
#
# Purpose: Changes values in /etc/haproxy/haproxy.cfg and /etc/default/haproxy
# so that Systemd can do legacy reload versus seamless socket transfer


if [ "$#" -ne 1 ]; then
  echo Usage: reload\|reload-socket
  exit 1
fi

# make all lines relevant lines uncommented so double commenting does not happen
sed -i '/mode 660 level admin/s/^#//' /etc/haproxy/haproxy.cfg
sed -i '/mode 777 level admin expose-fd/s/^#//' /etc/haproxy/haproxy.cfg
sed -i '/RELOADOPTS/s/^#//' /etc/default/haproxy

echo Changing configs so that Systemd does $1
if [ "$1" == "reload" ]; then
	# add comment to line
	sed -i '/mode 777 level admin expose-fd/s/^/#/g' /etc/haproxy/haproxy.cfg
	sed -i '/RELOADOPTS/s/^/#/g' /etc/default/haproxy

elif [ "$1" == "reload-socket" ]; then

	# add comment to line
	sed -i '/mode 660 level admin/s/^/#/g' /etc/haproxy/haproxy.cfg

else
	echo Did not recognize mode.  Only 'reload' and 'reload-socket' are valid values
fi


