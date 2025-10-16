ifneq ($(KERNELRELEASE),)
obj-m := serial.o
else
KDIR := $(HOME)/linux-kernel-bbb-labs/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
endif
