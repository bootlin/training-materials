#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define ALLOC_COUNT	10

static void *small_array[ALLOC_COUNT];

static void allocate_small(void)
{
	int i;

	for (i = 0; i < ALLOC_COUNT; i++) {
		small_array[i] = malloc(10000);
		usleep(100);
	}
}

static void free_small(void)
{
	int i;

	for (i = 0; i < ALLOC_COUNT; i++)
		free(small_array[i]);
}

static void allocate_temporary(void)
{
	int i;
	void *array[ALLOC_COUNT];

	for (i = 0; i < ALLOC_COUNT; i++) {
		array[i] = malloc(10000);
		memset(array[i], 0x0, 10000);
		free(array[i]);
		usleep(100);
	}
}

static void allocate_large()
{
		int i;
	void *array[ALLOC_COUNT];

	for (i = 0; i < ALLOC_COUNT; i++) {
		array[i] = malloc(i * 10000);
		usleep(100);
	}
}

static void allocate(void)
{
	allocate_large();
	allocate_small();
	allocate_temporary();
	free_small();
}

int main(int argc, char **argv)
{
	allocate();

	return 0;
}