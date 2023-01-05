#include <gpiod.h>
#include <stdio.h>
#include <unistd.h>
#include <malloc.h>
#include <sys/mman.h>
#include <time.h>
#include <string.h>
#include <sys/time.h>
#include <sys/resource.h>

#ifndef	CONSUMER
#define	CONSUMER	"Consumer"
#endif

static void usage() {
	printf("gpiotest <gpiochip_in> <gpio_in> <gpiochip_out> <gpio_out> [h] [p]\n");
	exit(1);
}

int main(int argc, char **argv)
{
	struct timespec ts = { 1, 0 };
	struct gpiod_line_event event;
	struct gpiod_chip *input_chip, *output_chip;
	struct gpiod_line *input_line, *output_line;
	int i, ret;

	char *input_chip_name;
	char *output_chip_name;
	unsigned int input_line_num;
	unsigned int output_line_num;
	bool save = false;
	bool heap_save = false;
	bool prefault = false;

	struct timespec stack_ts_buffer[4096];
	struct timespec *heap_ts_buffer;

	if (argc < 5)
		usage();

	input_chip_name = argv[1];
	input_line_num = atoi(argv[2]);

	output_chip_name = argv[3];
	output_line_num = atoi(argv[4]);

	if (argc > 5) {
		if (!strcmp(argv[5], "h"))
			heap_save = true;
		save = true;
	}

	if (argc > 6) {
		if (!strcmp(argv[6], "p"))
			prefault = true;
	}

	input_chip = gpiod_chip_open_by_name(input_chip_name);
	if (!input_chip) {
		perror("Open input chip failed\n");
		ret = -1;
		goto end;
	}

	output_chip = gpiod_chip_open_by_name(output_chip_name);
	if (!output_chip) {
		perror("Open output chip failed\n");
		ret = -1;
		goto end;
	}

	input_line = gpiod_chip_get_line(input_chip, input_line_num);
	if (!input_line) {
		perror("Get input line failed\n");
		ret = -1;
		goto close_chip;
	}

	output_line = gpiod_chip_get_line(output_chip, output_line_num);
	if (!output_line) {
		perror("Get input line failed\n");
		ret = -1;
		goto close_chip;
	}

	ret = gpiod_line_request_both_edges_events(input_line, CONSUMER);
	if (ret < 0) {
		perror("Request event notification failed\n");
		ret = -1;
		goto release_line;
	}

	ret = gpiod_line_request_output(output_line, CONSUMER, 0);
	if (ret < 0) {
		perror("Request event notification failed\n");
		ret = -1;
		goto release_line;
	}

	if (heap_save) {
		heap_ts_buffer = malloc(4096 * sizeof(struct timespec));
		if (!heap_ts_buffer)
			return -1;
	}

	if (prefault) {
		mlockall(MCL_CURRENT | MCL_FUTURE);
		mallopt(M_TRIM_THRESHOLD, -1);
		mallopt(M_MMAP_MAX, 0);

		if (heap_save)
			memset(heap_ts_buffer, 0, 4096 * sizeof(struct timespec));
		else
			memset(stack_ts_buffer, 0, sizeof(stack_ts_buffer));

	}

	i = 0;
	while (true) {
		ret = gpiod_line_event_wait(input_line, &ts);
		if (ret < 0) {
			perror("Wait event notification failed\n");
			ret = -1;
			goto release_line;
		} else if (ret == 0) {
			continue;
		}

		ret = gpiod_line_event_read(input_line, &event);
		if (ret < 0) {
			perror("Read last event notification failed\n");
			ret = -1;
			goto release_line;
		}

		if (save) {

			if (heap_save)
				heap_ts_buffer[i] = event.ts;
			else
				stack_ts_buffer[i] = event.ts;

			i++;
			if (i >= 4096)
				i = 0;
		}

		gpiod_line_set_value(output_line,
				    event.event_type == GPIOD_LINE_EVENT_RISING_EDGE ? 1 : 0);

	}

	ret = 0;

release_line:
	gpiod_line_release(input_line);
	gpiod_line_release(output_line);
close_chip:
	gpiod_chip_close(input_chip);
	gpiod_chip_close(output_chip);
end:
	return ret;
}
