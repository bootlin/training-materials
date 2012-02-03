obj-m := netdrv.o

KDIR := $(HOME)/felabs/linux/networking/linux-X.Y.Z
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

clean:
	$(RM) -f modules.order Module.symvers *~ *.ko *.o *.mod.c *.mod.o .*.cmd
	$(RM) -rf .tmp_versions
