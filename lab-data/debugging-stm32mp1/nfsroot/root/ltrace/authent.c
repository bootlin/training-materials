#include <authent_library.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
	int ret;
	void *ctx;

	ret = al_init();
	if (ret) {
		printf("Failed to initialize authent library\n");
		return EXIT_FAILURE;
	}

	ctx = al_alloc_context();
	if (!ctx)
		return EXIT_FAILURE;

	al_build_user_list(ctx);

	ret = al_authent_user(ctx, "user", "mysecretpassword");
	if (ret) {
		printf("Failed to authenticate user\n");
		return EXIT_FAILURE;
	}

	printf("Authentication successful\n");

	al_free_context(ctx);

	al_deinit();
	
	return EXIT_SUCCESS;
}