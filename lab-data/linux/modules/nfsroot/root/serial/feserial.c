#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>

/* Add your code here */

static int feserial_probe(struct platform_device *pdev)
{
	pr_info("Called feserial_probe\n");
	return 0;
}

static int feserial_remove(struct platform_device *pdev)
{
	pr_info("Called feserial_remove\n");
        return 0;
}

static struct platform_driver feserial_driver = {
        .driver = {
                .name = "feserial",
                .owner = THIS_MODULE,
        },
        .probe = feserial_probe,
        .remove = feserial_remove,
};

module_platform_driver(feserial_driver);
MODULE_LICENSE("GPL");
