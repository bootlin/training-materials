ifneq ($(KERNELRELEASE),)
obj-m := hello_version.o
else
KDIR := $(HOME)/felabs-kernel/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
