/* Vista emulator on Linux
 * Copyright 2002, B. Gates
 *
 * Permission to run this program without restriction,
 * especially on Linux systems!
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int cycles = 0;

void bsod (char *msg)
{
	printf ("%s", msg);
	exit (EXIT_FAILURE);
}

int file_exists(const char * filename)
{
    FILE *file;

    if (file = fopen(filename, "r"))
    {
        fclose(file);
        return 1;
    }
    return 0;
}


void log_activity (void *buffer)
{
	/* Look for traces of "Premium" content in system memory */

	if (strstr(buffer, "Mickey Mouse"))
	{
		bsod("Found unencrypted media on your system. Calling the cops\n");
	}

	++cycles;
}

int init_resources (void)
{
	void *buffer;
	int buffer_size = 655360; /* 640 KB, the limit that can never be exceeded */
	buffer = malloc(buffer_size);
	log_activity(buffer);
}

int main (void)
{
	int i;

	do
	{
		/* Refuse to run until the activation key file is found */

		while (! file_exists("/etc/vista.key"))
		{
		      sleep(1);
		}

		/* Now, start gathering system resources */

		for (i=0; i < 10000; i++)
		{
			init_resources();
		}

	} while (cycles < 100);

	bsod ("ERROR: Vista has been running for too long\nRestart it to improve performance\n");
}
