#include <stdint.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	uint32_t alloc_size = atoi(argv[1]);
	volatile uint32_t *array = (uint32_t *) malloc(alloc_size * sizeof(uint32_t));

	for (uint32_t i = 0; i < alloc_size; i++) {
		array[i] = ((i & 0xFF) << 24) |
			   (((i >> 8) & 0xFF) << 16) |
			   (((i >> 16) & 0xFF) << 8) |
			   (i >> 24);
	}

	return 0;
}