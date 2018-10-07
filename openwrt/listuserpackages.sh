#!/bin/ash

packages="$(cat /usr/lib/opkg/status | grep -n 'user install' | cut -d ':' -f1)"

printf %s "$packages" | while IFS= read -r nline; do
  echo -n "opkg install "
  sed -n 1,$nline' s/Package/&/p' /usr/lib/opkg/status | tail -n 1 | awk '{print $2}'
done
