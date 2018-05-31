#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>

/* Add your code here */

static int serial_probe(struct platform_device *pdev)
{
	pr_info("Called serial_probe\n");
	return 0;
}

static int serial_remove(struct platform_device *pdev)
{
	pr_info("Called serial_remove\n");
        return 0;
}

static struct platform_driver serial_driver = {
        .driver = {
                .name = "serial",
                .owner = THIS_MODULE,
        },
        .probe = serial_probe,
        .remove = serial_remove,
};

module_platform_driver(serial_driver);
MODULE_LICENSE("GPL");
