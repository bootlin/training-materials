ifneq ($(KERNELRELEASE),)
obj-m := nunchuk.o
else
KDIR := $(HOME)/felabs-kernel/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
