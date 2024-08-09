CC=${CROSS_COMPILE}gcc

all: trace_programs

trace_programs: trace_programs.c trace_programs.skel.h
	$(CC) $< -lbpf -o $@

vmlinux.h:
	bpftool btf dump file $(KDIR)/vmlinux format c > vmlinux.h

%.bpf.o: %.bpf.c vmlinux.h
	clang -D__TARGET_ARCH_arm -Wall -Werror -Wextra -target bpf -g -O2 -c $< -o $@

%.skel.h: %.bpf.o
	bpftool gen skeleton $< name $* > $@

clean:
	rm -rf *.o *.skel.h trace_programs vmlinux.h

.PHONY:clean