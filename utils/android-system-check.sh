#!/bin/bash

# Use this script to make sure that each training PC has the right
# hardware, distribution and configuration.

# Written by Chris Simmonds
# Version 1.0: 18th January 2013
# Version 1.1: 4th August 2013. Added work-around for 12.04.2 libgl1-mesa-glx:i386
# Version 1.2: 20th February 2014 - Drop Ubuntu 10.04. Ask for 4 GiB of RAM

echo
echo "This script will check that this PC is suitable for building Android"
echo
echo "Checking hardware..."

FAILED=n

NUM_CPU=$(grep processor /proc/cpuinfo | wc -l)
echo -n "Number of CPU's: ${NUM_CPU}, "
if [ ${NUM_CPU} -eq 1 ]; then
    echo "FAIL. Only one CPU: not powerful enough"
    FAILED=y
else
    echo "OK"
fi

RAM_KBYTES=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_MBYTES=$(( ${RAM_KBYTES} / 1024 ))
echo -n "MiB of RAM: ${RAM_MBYTES}, "
if [ ${RAM_MBYTES} -lt 4096 ]; then
    echo "FAIL. Only ${RAM_MBYTES} MiB RAM: we need at least 4 GiB"
    FAILED=y
else
    echo "OK"
fi

DISK_KBYTES=$(df  ${HOME} | awk '{if (NR == 2) print $4}')
DISK_GBYTES=$(( ${DISK_KBYTES} / 1048576 ))
echo -n "Free disk space in directory ${HOME}: ${DISK_GBYTES} GiB, "
if [ ${DISK_GBYTES} -le 49 ]; then
    echo "FAIL. Insufficient disk space in ${HOME}, we need at least 50 GiB"
    FAILED=y
else
    echo "OK"
fi

# Check the distribution is Ubuntu 12.04
echo -n "Checking Linux distribution, "
DISTRIB_RELEASE=x
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
fi
if [ $DISTRIB_RELEASE != "12.04" ]; then
    echo "FAIL. The distribution must be Ubuntu 64-bit 12.04"
    FAILED=y
else
    echo "OK"
fi

MACHINE_ARCH=$(uname -m)
echo -n "Machine architecture: ${MACHINE_ARCH}, "
if [ ${MACHINE_ARCH} != "x86_64" ]; then
    echo "FAIL. Must be 64-bit"
    FAILED=y
else
    echo "OK"
fi
if [ $FAILED == y ]; then
    echo
    echo FAIL
    echo
    exit 1
fi

echo
echo "PASS"
echo

exit 0
