#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#define __TARGET_ARCH_arm
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

#define MAX_FILENAME_LEN 32

SEC("ksyscall/execve")
int BPF_KPROBE_SYSCALL(trace_execve, const char *path, char *const _Nullable argv[],
               char *const _Nullable envp[])

{
	int pid = bpf_get_current_pid_tgid() & 0xFFFFFFFF;
	char fmt[] = "New process %d running program %s";

	bpf_trace_printk(fmt, sizeof(fmt), pid, path);
	return 0;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
