/* Small program to test high-resolution timers
 * and scheduling latency in Unix / Linux
 *
 * Copyright (c) 2007-2008, Free Electrons
 * http://free-electrons.com/labs/solutions/cypfig/rttest.c
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>

#include <sys/mman.h>

#define MAX(a,b)	(((a) > (b)) ? (a) : (b))
#define MIN(a,b)	(((a) < (b)) ? (a) : (b))

unsigned long long int timespec_diff(struct timespec *t2, struct timespec *t1)
{
	/* Computes the time difference between 2 timespecs */
	/* Assumes that t2 > t1!			    */

	return (t2->tv_sec - t1->tv_sec) * 1000000000ULL + t2->tv_nsec - t1->tv_nsec;
}

void timespec_add_ns(struct timespec *ts, unsigned ns)
{
	ts->tv_nsec += ns;
	if (ts->tv_nsec >= 1000000000) {
		ts->tv_nsec -= 1000000000;
		ts->tv_sec++;
	}
}

int main (void)
{
	struct timespec start_time, time1, time2;
	unsigned long long int jitter;
	unsigned long long int min_jit = 999999999999999ULL;
	unsigned long long int max_jit = 0ULL;
	unsigned long long sum_jit = 0ULL;
	unsigned samples = 0;

	mlockall(MCL_CURRENT | MCL_FUTURE);

	/* Display clock resolution */
	clock_getres(CLOCK_MONOTONIC, &time1);
	printf("Clock resolution (ns): %lu\n", time1.tv_nsec);
	
	/* Initialize the timer that will be used in nanosleep(),	*/
	/* to a value of 100 us						*/

	printf("Measurement, please wait 1 minute...\n");
	fflush(stdout);
	clock_gettime(CLOCK_MONOTONIC, &start_time);

	do {
		/* Get the date before sleeping */
		clock_gettime(CLOCK_MONOTONIC, &time1);

		/* Compute the wake-up date */
		timespec_add_ns(&time1, 100000);

		/* Sleep */
		clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &time1, NULL);
	
		/* Get the wake-up date */
		clock_gettime(CLOCK_MONOTONIC, &time2);
	
		/* skip the first second for warmup */
		if (samples >= 1) {
			/* Compute the sleep time */
			jitter = timespec_diff(&time2, &time1);
			min_jit = MIN(min_jit, jitter);
			max_jit = MAX(max_jit, jitter); 
			sum_jit += jitter;
		}
		++samples;
	} while (timespec_diff(&time2, &start_time) < 60000000000ULL);

	/* Display sleeping statistics */
	printf ("Samples: %u\n", --samples);
	printf ("Min latency: %llu us\n", min_jit / 1000);
	printf ("Max latency: %llu us\n", max_jit / 1000);
	printf ("Average latency: %llu us\n", (sum_jit / samples) / 1000);
	exit(EXIT_SUCCESS);
}
