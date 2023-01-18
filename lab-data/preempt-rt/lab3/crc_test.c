#include <time.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <inttypes.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <malloc.h>
#include <sys/mman.h>

#define DATA_SIZE	(16 * 1024 * 1024)

#define SEC_TO_NSEC	1000000000ULL

static uint64_t timespec_to_nano(struct timespec *spec)
{
	return spec->tv_sec * SEC_TO_NSEC + spec->tv_nsec;
}

uint32_t crc32_for_byte(uint32_t r)
{
	for (int j = 0; j < 8; ++j)
		r = (r & 1 ? 0 : (uint32_t)0xEDB88320L) ^ r >> 1;

	return r ^ (uint32_t)0xFF000000L;
}

static uint32_t crc_table[0x100];

static void init_crc_table(void)
{
	size_t i;

	for (i = 0; i < 0x100; i++)
		crc_table[i] = crc32_for_byte(i);
}

static uint32_t crc32(const void *data, size_t n_bytes)
{
	uint32_t crc = 0;
	size_t i;

	for (i = 0; i < n_bytes; i++)
		crc = crc_table[(uint8_t)crc ^ ((uint8_t *)data)[i]] ^ crc >> 8;

	return crc;
}

void init_rt() {
	char *buff;

	mlockall(MCL_CURRENT | MCL_FUTURE);
	mallopt(M_TRIM_THRESHOLD, -1);
	mallopt(M_MMAP_MAX, 0);

	buff= malloc(2 * DATA_SIZE);
	memset(buff, 0, 2 * DATA_SIZE);
	free(buff);

}

int main(int argc, char **argv)
{
	int fd;
	int i = 0;
	uint32_t crc;
	char *data;
	ssize_t ret;
	uint64_t start_nano, end_nano;
	struct timespec start = {0, 0}, end = {0, 0};

	init_crc_table();

	//init_rt();

	data = malloc(DATA_SIZE);
	while (1) {


		clock_gettime(CLOCK_MONOTONIC, &start);
		start_nano = timespec_to_nano(&start);

		if (!data) {
			fprintf(stderr, "Failed to allocate %d bytes\n", DATA_SIZE);
			return EXIT_FAILURE;
		}

		memset(data, i++, DATA_SIZE);
		crc = crc32(data, DATA_SIZE);

		clock_gettime(CLOCK_MONOTONIC, &end);
		end_nano = timespec_to_nano(&end);


		printf("Computed crc 0x%" PRIx32 " in %" PRIu64 " nano\n", crc, end_nano - start_nano);
		sleep(1);
	}
	free(data);

	return 0;
}
