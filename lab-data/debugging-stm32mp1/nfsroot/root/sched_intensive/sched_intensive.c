#include <unistd.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SEC_TO_NSEC	1000000000ULL
#define MSEC_TO_USEC	1000ULL
#define MSEC_TO_NSEC	1000000ULL

static uint64_t timespec_to_nano(struct timespec *spec)
{
	return spec->tv_sec * SEC_TO_NSEC + spec->tv_nsec;
}

static void work(uint64_t busy_time_msec)
{
	struct timespec start = {0, 0}, end = {0, 0};
	uint64_t start_nano, end_nano, work_time_nano;

	printf("Starting to work\n");

	clock_gettime(CLOCK_MONOTONIC, &start);
	start_nano = timespec_to_nano(&start);

	work_time_nano = busy_time_msec * MSEC_TO_NSEC;

	do {
		clock_gettime(CLOCK_MONOTONIC, &end);
		end_nano = timespec_to_nano(&end);
	} while ((end_nano - start_nano) < work_time_nano);
}

int main(int argc, char **argv)
{
	int ret;
	struct sched_param param;
	uint64_t sleep_time = 0;
	uint64_t busy_time = 0;

	if (argc < 3) {
		fprintf(stderr, "%s <sleep_time_msec> <work_time_msec> ", argv[0]);
		return 0;
	}
	
	sleep_time = atoi(argv[1]) * MSEC_TO_USEC;
	busy_time = atoi(argv[2]);

	printf("Sleeping for %d msec and working for %d msec\n", sleep_time, busy_time);

	memset(&param, 0, sizeof(param));

	param.sched_priority = 99;

	ret = sched_setscheduler(getpid(), SCHED_FIFO, &param);
	if (ret) {
		perror("Failed to set scheduler");
		return ret;
	}

	while(1) {
		usleep(sleep_time);
		work(busy_time);
	}
}