#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run this script as root"
  exit
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 mmc_device"
  exit
fi

[[ $1 =~ mmcblk[0-9]+ ]] && delim='p'

dd if=/dev/zero of=$1 bs=1M count=16
if [ "$2" == "--compatibility" ]; then
  sfdisk --in-order --L --unit M $1 <<EOF
1,48,0xE,*
,,,-
EOF
else
  sfdisk $1 <<EOF
1M,48M,0xE,*
,,,-
EOF
fi

mkfs.vfat -F 16 ${1}${delim}1 -n boot
mkfs.ext4 ${1}${delim}2 -L rootfs

exit 0
