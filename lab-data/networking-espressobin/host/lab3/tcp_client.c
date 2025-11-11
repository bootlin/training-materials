#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>

void usage()
{
	fprintf(stderr, "./tcp_client <address> <port>\n");
	exit(-1);
}

int main(int argc, char *argv[])
{
	/* variable definitions */

	if (argc < 3)
		usage();

	/* TCP client implementation */

	return 0;
}
