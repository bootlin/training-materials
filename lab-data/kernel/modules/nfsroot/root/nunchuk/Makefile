ifneq ($(KERNELRELEASE),)
obj-m := nunchuk.o
else
KDIR := $(HOME)/felabs/linux/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
