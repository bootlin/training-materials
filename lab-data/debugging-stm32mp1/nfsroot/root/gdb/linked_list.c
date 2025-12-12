/* SPDX-License-Identifier: GPL-2.0-only */

#include <sys/queue.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define WORD_LIST	"./word_list"

struct name {
	int index;
	char name[8];
	SLIST_ENTRY(name) next;
};

SLIST_HEAD(name_list, name) name_list;

static int insert_name(const char *word, int index)
{
	struct name *name;

	name = malloc(sizeof(*name));
	if (!name)
		return 1;

	SLIST_INSERT_HEAD(&name_list, name, next);
	strcpy(name->name, word);
	/* Remove the trailing newline */
	name->name[strlen(name->name) - 1] = '\0';
	name->index = index;

	return 0;
}

static int load_words(const char *word_file)
{
	FILE *file;
	size_t read;
	char *line = NULL;
	size_t len;
	int index = 0;

	file = fopen(word_file, "r");
	if (!file) {
		perror("Failed to open word list");
		return 1;
	}

	while ((read = getline(&line, &len, file)) != -1) {
		if (insert_name(line, index++))
			return 1;
	}

	return 0;
}

void display_linked_list(void)
{
	struct name *name;

	SLIST_FOREACH(name, &name_list, next) {
		printf("[%d] Name: %s\n", name->index, name->name);
	};
}

int main(int argc, char **argv)
{
	int ret;
	const char *word_list = WORD_LIST;

	if (argc < 2)
		fprintf(stderr, "Missing word list, using default %s\n", word_list);
	else
		word_list = argv[1];
	
	ret = load_words(word_list);
	if (ret)
		fprintf(stderr, "Failed to load word list\n");

	display_linked_list();

	return ret;
}
