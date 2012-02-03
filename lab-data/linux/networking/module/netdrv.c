#include <linux/module.h>

static int __init netdrv_init(void)
{
	return 0;
}

static void __exit netdrv_exit(void)
{
}

module_init(netdrv_init);
module_exit(netdrv_exit);
MODULE_LICENSE("GPL");

