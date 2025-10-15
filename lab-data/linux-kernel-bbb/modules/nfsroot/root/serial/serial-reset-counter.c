#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#define SERIAL_RESET_COUNTER 0
#define SERIAL_GET_COUNTER 1

int main(int argc, char *argv[])
{
	int fd, ret;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s /dev/UART\n", argv[0]);
		exit(1);
	}

	fd = open(argv[1], O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "Unable to open %s: %s\n", argv[1],
			strerror(errno));
		exit(1);
	}

	ret = ioctl(fd, SERIAL_RESET_COUNTER);
	if (ret < 0) {
		fprintf(stderr, "Unable to reset counter: %s\n",
			strerror(errno));
		close(fd);
		exit(1);
	}

	ret = close(fd);
	if (ret < 0) {
		fprintf(stderr, "Unable to close %s: %s\n", argv[1],
			strerror(errno));
		exit(1);
	}

	printf("Counter reset\n");
	return 0;
}
