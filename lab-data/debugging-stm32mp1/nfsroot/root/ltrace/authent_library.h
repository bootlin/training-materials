/* SPDX-License-Identifier: GPL-2.0-only */

#ifndef AL_HEADER
#define AL_HEADER

int al_init(void);
void *al_alloc_context(void);
void al_build_user_list(void *ctx);
int al_authent_user(void *ctx, const char *user, const char *password);
void al_free_context(void *ctx);
void al_deinit();

#endif /* AL_HEADER */