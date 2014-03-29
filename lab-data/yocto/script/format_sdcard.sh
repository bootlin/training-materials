#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run this script as root"
  exit
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 mmc_device"
  exit
fi

exec 1>&-
exec 2>&-

dd if=/dev/zero of=$1 bs=1M count=16
sfdisk --in-order --L --unit M $1 <<EOF
1,48,0xE,*
,,,-
EOF

mkfs.vfat -F 16 ${1}p1 -n boot
mkfs.ext4 ${1}p2 -L rootfs

exit 0
