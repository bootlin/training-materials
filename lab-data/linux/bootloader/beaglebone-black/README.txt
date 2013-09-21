Compiling instructions
----------------------

Tested on Ubuntu 13.04

Install the Linaro toolchain:
sudo apt-get install gcc-arm-linux-gnueabi
(the version at the time of our testing was 4:4.7.2-1)

Clone the mainline U-boot sources:
git clone git://git.denx.de/u-boot.git
git tag
git checkout v2013.10-rc3

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
make distclean
make am335x_evm_config
make

This produces the MLO and u-boot.img files that
you need to boot your BeagleBone Black.
