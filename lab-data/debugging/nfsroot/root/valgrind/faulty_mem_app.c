#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

static int *allocate_array(int size)
{
	return malloc(size * sizeof(int));
}

static void clear_array(int *p, int size)
{
	int i;

	for (i = 0; i <= size; i++)
		p[i] = 0;
}

static void write_file(int *p, int size)
{
	int fd;

	fd = creat("/tmp/seq", S_IRWXU);
	if (fd < 0)
		return;

	write(fd, p, size * sizeof(int));
	close(fd);
}

static void fill_sequential(int *p, int size)
{
	int i;

	for (i = 0; i < size - 1; i++)
		p[i] = i;
}

static void do_something(int size)
{
	int *p = allocate_array(size);
	if (!p)
		return;

	fill_sequential(p, size);
	write_file(p, size);
	clear_array(p, size);
}

int main(void)
{
	do_something(100);
	do_something(200);
}
