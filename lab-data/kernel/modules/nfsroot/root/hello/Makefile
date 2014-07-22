ifneq ($(KERNELRELEASE),)
obj-m := hello_version.o
else
KDIR := $(HOME)/felabs/linux/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
