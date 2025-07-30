/* nunchuk-mpd-client
   (c) 2022 Bootlin <michael.opdenacker@bootlin.com>

   License: Public Domain
*/

#include <dirent.h>
#include <mpd/client.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/input.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

static int handle_error(struct mpd_connection *c)
{
	fprintf(stderr, "%s\n", mpd_connection_get_error_message(c));
	mpd_connection_free(c);
	return EXIT_FAILURE;
}

static void change_volume(struct mpd_connection *c, int delta)
{
	int volume;
	if (!mpd_run_change_volume(c, delta))
		exit(handle_error(c));

        volume = mpd_run_get_volume(c);

        if (volume == -1)
		exit(handle_error(c));

	printf("%d\n", volume);
}

static void print_current_song(struct mpd_connection *c)
{
	struct mpd_song *song;
	song = mpd_run_current_song(c);

	if (song) {
		printf("%s (%u s)\n", mpd_song_get_uri(song), mpd_song_get_duration(song));
                mpd_song_free(song);
        }
}

static int is_event_device(const struct dirent *dir) {
        return (strncmp("event", dir->d_name, 5) == 0);
}

int main(int argc, char ** argv)
{
	struct mpd_connection *conn;
	int i, ndev, ret, fd, quit = 0, num_events = 0;
	struct input_event event;
	struct dirent **namelist;

        /* Find Nunchuk input device */

	ndev = scandir("/dev/input", &namelist, is_event_device, alphasort);

	if (ndev <= 0) {
		fprintf(stderr, "ERROR: no input event device found\n");
		exit(EXIT_FAILURE);
	}

        for (i = 0; i < ndev; i++)
        {
                char fname[256];
                char name[256];

                snprintf(fname, sizeof(fname), "/dev/%s", namelist[i]->d_name);
		free(namelist[i]);

                fd = open(fname, O_RDONLY);

                if (fd < 0)
                        continue;

                ioctl(fd, EVIOCGNAME(sizeof(name)), name);

		if (strcmp("Wii Nunchuck", name) == 0)
			break;
		else
			close(fd);

        }

	if (i == ndev) {
		fprintf(stderr, "ERROR: didn't manage to find the Nunchuk device in /dev/input. Is the Nunchuk driver loaded?\n");
		exit(EXIT_FAILURE);
        }

	/* Connection to MPD on localhost, default port */

	conn = mpd_connection_new(0, 0, 30000);

	if (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS)
		return handle_error(conn);

	printf("Connection successful\n");

	/* Main loop */

	while (!quit) {
		ret = read(fd, &event, sizeof(struct input_event));
		num_events++;

		switch (event.type) {
		case EV_KEY:
			switch (event.code) {
			case BTN_Z:
				if (event.value == 1) {
					printf("Play/Pause\n");
					if (!mpd_run_toggle_pause(conn))
						return handle_error(conn);
				}
				break;
			case BTN_C:
				if (event.value == 1) {
					printf("Quit\n");
					quit = 1;
					free(conn);
				}
				break;
			}
			break;
		case EV_ABS:
			switch (event.code) {
			case ABS_Y:
				if (event.value > 250) {
					printf("Volume up: ");
					change_volume(conn, 5);
				} else if (event.value < 5) {
					printf("Volume down: ");
					change_volume(conn, -5);
				}
				break;
			case ABS_X:
				if (event.value > 250) {
					if (!mpd_run_next(conn)) {
						printf("No next song. Aborting\n");
						exit(handle_error(conn));
					} else {
						printf("Next song: ");
						print_current_song(conn);
					}
				}
				else if (event.value < 5) {
					if (!mpd_run_previous(conn)) {
						printf("No previous song. Aborting\n");
						exit(handle_error(conn));
					} else {
						printf("Previous song: ");
						print_current_song(conn);
					}
				}
				break;
			}
			break;
		}
	}

	/* Close connection */
	mpd_connection_free(conn);
	printf("Connection terminated\n");
	return 0;
}
