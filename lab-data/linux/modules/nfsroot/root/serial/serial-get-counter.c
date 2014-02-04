#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>

#define SERIAL_RESET_COUNTER 0
#define SERIAL_GET_COUNTER 1

int main(void)
{
    unsigned int val;
    int fd, ret;

    fd = open("/dev/serial", O_RDWR);
    if (fd < 0) {
        fprintf(stderr, "Unable to open /dev/serial\n");
        exit (1);
    }

    ret = ioctl(fd, SERIAL_GET_COUNTER, & val);
    if (ret < 0) {
        fprintf(stderr, "Unable to get counter\n");
        exit (1);
    }

    printf("Counter value: %d\n", val);
    return 0;
}
