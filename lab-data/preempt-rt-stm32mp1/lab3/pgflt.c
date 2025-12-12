#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <malloc.h>
#include <sys/mman.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

void timestamp(const char *msg, int val)
{
	static struct timespec tsl;
	static long minfltl;

	struct timespec ts;
	unsigned long diff;
	struct rusage r;
	long rdiff;

	clock_gettime(CLOCK_MONOTONIC, &ts);
	getrusage(RUSAGE_SELF, &r);

	if (tsl.tv_sec != 0) {
		diff = (ts.tv_sec - tsl.tv_sec) * 1000000000;
		diff += ts.tv_nsec - tsl.tv_nsec;

		rdiff = r.ru_minflt - minfltl;

		printf("% 10d ns % 5ld faults : %s", diff, rdiff, msg);
		if (val >= 0)
			printf(" (%d)", val);
		printf("\n");
	}

	tsl = ts;
	minfltl = r.ru_minflt;
}

/* 10 MiB */
#define SIZE (10 * 1024 * 1024)

void testfunc_malloc(void)
{
	char *p;

	p = malloc(SIZE);
	if (!p) {
		fprintf(stderr, "MALLOC FAILED: %s:%d\n", __FILE__, __LINE__);
		return;
	}

	memset(p, 42, SIZE);

	if (p[SIZE - 1] != 42)
		fprintf(stderr, "MEMSET FAILED: %s:%d\n", __FILE__, __LINE__);

	free(p);
}

void recursive_stack(int i)
{
	char buf[1024];
	if (i > 0)
		recursive_stack(i - 1);
}

void testfunc_deepstack(void)
{
	char buf[1024];
	recursive_stack(7 * 1024);
}

void prefault_stack(void)
{
#define STACK_SIZE (7680 * 1024) /* 7.5 MiB */
	char buf[STACK_SIZE];
	long pagesize;
	int i;

	pagesize = sysconf(_SC_PAGESIZE);

	for (i = 0; i < STACK_SIZE; i += pagesize)
		buf[i] = 0;
}

void prefault_heap(void)
{
#define HEAP_SIZE (20 * 1024 * 1024) /* 20 MiB */
	long pagesize;
	char *buf;
	int i;

	pagesize = sysconf(_SC_PAGESIZE);

	buf = malloc(HEAP_SIZE);
	if (!buf) {
		fprintf(stderr, "MALLOC FAILED: %s:%d\n", __FILE__, __LINE__);
		return;
	}

	for (i = 0; i < HEAP_SIZE; i += pagesize)
		buf[i] = 0;

	free(buf);
}

void setup_rt(unsigned int opts)
{
	if (opts & 0x1) {
		if (mallopt(M_TRIM_THRESHOLD, -1) == 0) {
			fprintf(stderr, "MALLOPT FAILED: %s:%d\n",
				__FILE__, __LINE__);
		}

		if (mallopt(M_MMAP_MAX, 0) == 0) {
			fprintf(stderr, "MALLOPT FAILED: %s:%d\n",
				__FILE__, __LINE__);
		}
	}

	if (opts & 0x2) {
		if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1) {
			fprintf(stderr, "MLOCKALL FAILED: %s:%d\n",
				__FILE__, __LINE__);
		}
	}

	if (opts & 0x4)
		prefault_stack();

	if (opts & 0x8)
		prefault_heap();
}


static void usage(const char *cmd)
{
	printf("usage: %s [opts-bitmask]\n", cmd);
	printf("  opts-bits:\n");
	printf("  0x01 = mallopt\n");
	printf("  0x02 = mlockall\n");
	printf("  0x04 = prefault-stack\n");
	printf("  0x08 = prefault-heap\n");
	printf("  0x10 = run tests\n");
	printf("\n");
	printf("  0x10 = no rt tweaks + tests\n");
	printf("  0x1f = full rt tweaks + tests\n");
	printf("\n");
}

int main(int argc, char *argv[])
{
	unsigned int i;

	if (argc != 2) {
		usage(argv[0]);
		return 1;
	}

	if (sscanf(argv[1], "%x", &i) != 1) {
		usage(argv[0]);
		return 1;
	}

	printf("options: 0x%x\n", i);

	timestamp("init", -1);

	setup_rt(i);

	timestamp("main setup", -1);

	if (i & 0x10) {
		for (i = 0; i < 4; i++) {
			testfunc_malloc();
			timestamp("testfunc_malloc", i);
		}

		for (i = 0; i < 4; i++) {
			testfunc_deepstack();
			timestamp("testfunc_deepstack", i);
		}
	}

	return 0;
}
