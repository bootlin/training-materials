ifneq ($(KERNELRELEASE),)
obj-m := drvbroken.o
else
KDIR := $(HOME)/linux-kernel-stm32mp1-labs/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
endif
