#!/bin/bash
#
# makes sure data disk at /dev/sdb is formatted and mounted
# https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
#
# blog: https://fabianlee.org/2022/05/01/gcp-moving-a-vm-instance-to-a-different-region-using-snapshots/
#
# meant to be run inside GCP VM instance using startup metadata
# gcloud compute instances create .... --metadata-from-file=startup-script=gcp-add-data-disk.sh
#

set -x

# is /dev/sdb formatted to ext4?
if lsblk -f /dev/sdb | grep -q 'ext4' ; then
  echo "/dev/sdb already formatted"
else
  sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
fi

# is disk mounted?
findmnt /datadisk1
if [ $? -ne 0 ]; then
  sudo mkdir -p /datadisk1
  sudo mount -o discard,defaults /dev/sdb /datadisk1
  sudo chmod a+rw /datadisk1
fi

# is disk entry in fstab?
UUID=$(sudo blkid -s UUID -o value /dev/sdb)
if cat /etc/fstab | grep -q '/datadisk1' ; then
  echo "/datadisk1 already added to fstab, ensuring UUID is correct"
  sudo sed -i "s#^UUID=.* /datadisk1#UUID=$UUID /datadisk1#" /etc/fstab
else
  echo UUID=$UUID /datadisk1 ext4 discard,defaults,noatime,nofail 0 2 | sudo tee -a /etc/fstab
fi

# writes timestamp and current zone to file
file=/datadisk1/hello.txt
sudo touch $file
sudo chmod a+rw $file
date "+%F %T" | tee -a $file
curl -s http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | tee -a $file
echo "" | tee -a $file
