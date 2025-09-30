/* SPDX-License-Identifier: GPL-2.0-only */

#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int al_init(void)
{
	return 0;
}

void *al_alloc_context(void)
{
	return malloc(10);
}

void al_build_user_list(void *ctx)
{

}

int al_authent_user(void *ctx, const char *user, const char *password)
{
	if (strncmp(user, "root", 10) != 0)
		return 1;

	return 0;
}

void al_free_context(void *ctx)
{
	free(ctx);
}

void al_deinit()
{

}