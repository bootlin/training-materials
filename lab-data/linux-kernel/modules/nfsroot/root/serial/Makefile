ifneq ($(KERNELRELEASE),)
obj-m := feserial.o
else
KDIR := $(HOME)/felabs-kernel/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
