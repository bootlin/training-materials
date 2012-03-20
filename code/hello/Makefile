obj-m := hello.o

KDIR := /lib/modules/`uname -r`/build 
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
