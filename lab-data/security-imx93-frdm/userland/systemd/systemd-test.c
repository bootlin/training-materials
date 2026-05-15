#define _GNU_SOURCE

#include <fcntl.h>
#include <linux/prctl.h>
#include <linux/random.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/capability.h>
#include <sys/ioctl.h>
#include <sys/prctl.h>
#include <time.h>
#include <unistd.h>

#define WRITE_FILE "/var/cache/security_training_systemd"
#define WRITE_STRING "Hello!\n"
#define HOSTNAME "changed-hostname"
#define RANDOM_FILE "/dev/urandom"

int main()
{
	int fd;
	int ret;
	char buf[256];

	/* Write some data to a privileged file */
	fprintf(stderr, "Writing data to \"" WRITE_FILE "\"\n");
	fd = open(WRITE_FILE, O_CREAT | O_TRUNC | O_WRONLY, S_IRUSR | S_IWUSR);
	if (fd < 0) {
		perror("Failed to open \"" WRITE_FILE "\"");
		exit(1);
	} else {
		write(fd, WRITE_STRING, strlen(WRITE_STRING));
		close(fd);
	}

	/* Adding entropy to /dev/urandom */
	fprintf(stderr, "Adding entropy count\n");
	fd = open(RANDOM_FILE, O_WRONLY);
	if (fd < 0) {
		perror("Failed to open \"" RANDOM_FILE "\"");
	} else {
		struct rand_pool_info *pool_info = NULL;

		pool_info = malloc(sizeof(*pool_info) + sizeof(time_t));

		pool_info->entropy_count = 8;
		pool_info->buf_size = sizeof(time_t);
		*((time_t*) &pool_info->buf) = time(NULL);

		ret = ioctl(fd, RNDADDENTROPY, pool_info);
		if (ret != 0)
			perror("Failed to add entropy");

		free(pool_info);
		close(fd);
	}

	/* Set the hostname */
	fprintf(stderr, "Setting hostname to \"" HOSTNAME "\"\n");
	ret = sethostname(HOSTNAME, strlen(HOSTNAME));
	if (ret != 0) {
		perror("Failed to set hostname");
	}

	ret = gethostname(buf, sizeof(buf));
	if (ret != 0) {
		perror("Failed to retrieve hostname");
	} else {
		fprintf(stderr, "hostname: %s\n", buf);
	}

#if 0
	/* This is needed when starting the process outside of systemd, as a
	 * simple user.
	 * You need to ensure the file is set with the correct capabilities,
	 * with
	 * setcap cap_net_raw,cap_sys_admin=ep systemd-test
	 */

	cap_t caps;
	cap_flag_value_t cap_val;

	/* Add CAP_NET_RAW as ambient capability */
	caps = cap_get_proc();
	ret = cap_get_flag(caps, CAP_NET_RAW, CAP_PERMITTED, &cap_val);

	if ((ret != 0) || (cap_val != CAP_SET)) {
		fprintf(stderr,
			"CAP_NET_RAW capabilities is not permitted, ping will fail\n");
	} else {
		cap_value_t cap_value = CAP_NET_RAW;
		ret = cap_set_flag(caps, CAP_INHERITABLE, 1, &cap_value,
				   CAP_SET);
		if (ret == 0)
			ret = cap_set_proc(caps);
		if (ret == 0)
			ret = prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE,
				    CAP_NET_RAW, 0, 0);

		if (ret != 0)
			fprintf(stderr,
				"Failed to set CAP_NET_RAW as inheritable and ambient capability\n");
	}
	cap_free(caps);
#endif

	/* Execute ping */
	fprintf(stderr, "Executing ping command\n");
	fflush(NULL);

	execlp("ping", "ping", "-c", "1", "-N", "name", "google.com", NULL);

	return 0;
}
