#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <unistd.h>
#include <errno.h>

void usage()
{
	fprintf(stderr, "./monitor <interface>\n");
	exit(-1);
}

int main(int argc, char *argv[])
{
	/* variable definitions */

	if (argc < 2)
		usage();

	/* Monitor implementation */

	return 0;
}
