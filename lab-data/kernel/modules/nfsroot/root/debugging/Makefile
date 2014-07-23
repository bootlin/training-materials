ifneq ($(KERNELRELEASE),)
obj-m := drvbroken.o
else
KDIR := $(HOME)/felabs-kernel/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
