#include <stdio.h>
#include <stdlib.h>
#include <libconfig.h>

int main(void)
{
        config_t cfg;
        config_setting_t *setting;
        const char *str;

        config_init(&cfg);

	if (config_read_file(&cfg, "myapp.cfg") == CONFIG_FALSE)
        {
		fprintf(stderr, "Cannot open config file\n");
                config_destroy(&cfg);
		exit(1);
        }

	printf("Config file successfully opened\n");

	return 0;
}
