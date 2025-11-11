ifneq ($(KERNELRELEASE),)
obj-m := locking_test.o
else
KDIR ?= $(HOME)/debugging-stm32mp1-labs/src/linux
all:
	$(MAKE) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
endif
