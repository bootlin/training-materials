CC:=${CROSS_COMPILE}gcc
SYSROOT:=$(shell ${CC} --print-sysroot)

ifeq ($(KDIR),)
$(error You must set KDIR variable to the path of your kernel directory)
endif

ifeq ($(wildcard $(KDIR)/vmlinux),)
$(error Invalid vmlinux file path: $(KDIR)/vmlinux)
endif

all: trace_programs

trace_programs: trace_programs.c trace_programs.skel.h
	$(CC) $< -lbpf -o $@

vmlinux.h:
	bpftool btf dump file $(KDIR)/vmlinux format c > vmlinux.h

%.bpf.o: %.bpf.c vmlinux.h
	clang --sysroot=$(SYSROOT) -Wno-unused-parameter -target bpf -g -O2 -c $< -o $@

%.skel.h: %.bpf.o
	bpftool gen skeleton $< name $* > $@

clean:
	rm -rf *.o *.skel.h trace_programs vmlinux.h

.PHONY:clean
