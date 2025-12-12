// SPDX-License-Identifier: GPL-2.0-only

#define pr_fmt(fmt) "locking: " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/workqueue.h>
#include <linux/mutex.h>

static void my_work_fn(struct work_struct *work);
static DECLARE_WORK(my_custom_work, my_work_fn);

static DEFINE_MUTEX(mutex1);
static DEFINE_MUTEX(mutex2);

static void do_atomic_work(void)
{
	unsigned long flags;
	void *data;

	local_irq_save(flags); /* Disable interrupts */

	data = kmalloc(1024, GFP_KERNEL);
	/* Do something with the data */
	kfree(data);

	local_irq_restore(flags); /* Re-enable interrupts */
}

static void my_work_fn(struct work_struct *work)
{
	mutex_lock(&mutex1);
	mutex_lock(&mutex2);

	pr_info("Doing work !\n");

	mutex_unlock(&mutex2);
	mutex_unlock(&mutex1);
}

static int __init locking_init(void)
{
	schedule_work(&my_custom_work);

	mutex_lock(&mutex2);
	mutex_lock(&mutex1);

	pr_info("Doing some init work too !\n");

	mutex_unlock(&mutex1);
	mutex_unlock(&mutex2);

	return 0;
}

static void __exit locking_exit(void)
{
	do_atomic_work();
}

module_init(locking_init);
module_exit(locking_exit);
MODULE_LICENSE("GPL");
