ifneq ($(KERNELRELEASE),)
obj-m := bootlinlan.o
else
KDIR := $(LINUX_DIR)
all:
	$(MAKE) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
endif
