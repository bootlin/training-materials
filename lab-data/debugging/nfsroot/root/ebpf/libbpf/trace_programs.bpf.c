#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

#define MAX_FILENAME_LEN 32

SEC("kprobe/sys_execve")
int trace_execve(struct pt_regs *regs)
{
    char *filename = (char *)PT_REGS_PARM1(regs);
    int pid = bpf_get_current_pid_tgid() & 0xFFFFFFFF;
    char fmt[] = "New process %d running program %s";

    bpf_trace_printk(fmt, sizeof(fmt), pid, filename);
    return 0;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
