#define _GNU_SOURCE

#include <fcntl.h>
#include <linux/seccomp.h>
#include <seccomp.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>

#define READ_FILE "/proc/cmdline"
#define CMD "/bin/bash"

//#define USE_SECCOMP_FILTERS

void enable_seccomp(void)
{
#ifndef USE_SECCOMP_FILTERS
	syscall(SYS_seccomp, SECCOMP_SET_MODE_STRICT, 0, NULL);
#else
	scmp_filter_ctx ctx;
	int ret;

	ctx = seccomp_init(SCMP_ACT_KILL);

	ret = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit_group), 0);
	if (ret == 0)
		ret = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(write), 0);
	/* TODO: you will have to add missing rules */

	ret = seccomp_load(ctx);
	if (ret != 0) {
		perror("Failed to apply seccomp filter");
		exit(1);
	}
#endif
}

int main()
{
	int fd;
	char buf[256];
	size_t len;

	fd = open(READ_FILE, O_RDONLY);
	if (fd < 0) {
		perror("Failed to open \"" READ_FILE "\"");
		return 1;
	}

	//enable_seccomp();

	printf("Showing content of \"" READ_FILE "\":\n");
	while ((len = read(fd, buf, sizeof(buf) - 1)) > 0) {
		buf[len - 1] = '\0';
		printf("%s", buf);
	}
	close(fd);
	printf("\n");

	printf("Running \"" CMD "\":\n");
	execl(CMD, CMD, NULL);

	return 0;
}
