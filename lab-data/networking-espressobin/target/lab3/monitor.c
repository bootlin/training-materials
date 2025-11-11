#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <unistd.h>
#include <errno.h>

void hexdump(const char *buf, int size)
{
	int i;

	for (i = 0; i < size; i++) {
		if (!(i % 16))
			printf("\n%02x\t", (i & ~0xf));

		printf("%02x ", buf[i] & 0xff);
	}
	printf("\n");
}

void usage()
{
	fprintf(stderr, "./monitor <interface>\n");
	exit(-1);
}

int main(int argc, char *argv[])
{
	/* Declarations */

	if (argc < 2)
		usage();

	/* Monitoring code */

	return 0;
}
