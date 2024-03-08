// SPDX-License-Identifier: GPL-2.0
/* Voluntarily broken driver
 * Copyright Thomas Petazzoni <thomas.petazzoni@bootlin.com>
 * License: GNU General Public License 2.0 or later
 * Permission to break this driver even further!
 */
#include <linux/module.h>
#include <linux/errno.h>
#include <linux/fs.h>
#include <linux/cdev.h>

static dev_t broken_dev;
static int broken_first_minor;
static int broken_count = 1;
static struct cdev *broken_cdev;

static ssize_t
broken_write(struct file *file, const char __user *buf, size_t count,
	     loff_t *ppos)
{
	pr_info("Writing %ld bytes from %p to the device\n",
	      count, buf);
	return 0;
}

static ssize_t
broken_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
	pr_info("Writing %ld bytes to %p from the device\n",
	count, buf);
	return 0;
}

static const struct file_operations broken_fops = {
	.owner = THIS_MODULE,
	.read = broken_read,
	.write = broken_write,
};

int __init broken_init(void)
{
	if (alloc_chrdev_region(&broken_dev, broken_first_minor, 1, "broken") <
	    0) {
		pr_err("broken: unable to find free device numbers\n");
		return -EIO;
	}

	cdev_init(broken_cdev, &broken_fops);

	if (cdev_add(broken_cdev, broken_dev, 1) < 0) {
		pr_err("broken: unable to add a character device\n");
		unregister_chrdev_region(broken_dev, broken_count);
		return -EIO;
	}

	pr_info("Loaded the broken driver: major = %d, minor = %d\n",
	       MAJOR(broken_dev), MINOR(broken_dev));

	return 0;
}

void __exit broken_exit(void)
{
	cdev_del(broken_cdev);
	unregister_chrdev_region(broken_dev, broken_count);
	pr_info("Unloaded the broken driver!\n");
}

module_init(broken_init);
module_exit(broken_exit);

MODULE_AUTHOR("Thomas Petazzoni");
MODULE_DESCRIPTION("Broken device");
MODULE_LICENSE("GPL");
