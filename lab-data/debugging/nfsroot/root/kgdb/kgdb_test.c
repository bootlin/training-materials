// SPDX-License-Identifier: GPL-2.0-only

#include <linux/module.h>
#include <linux/delay.h>
#include <linux/kthread.h>

static struct task_struct *kthread;

static int kgdb_test_thread_routine(void *data)
{
	while(1) {
		usleep_range(1000, 2000);

		pr_debug("I'm awake !\n");

		if (kthread_should_stop())
			break;
	}

	return 0;
}

static int kgdb_test_init(void)
{
	kthread = kthread_create(kgdb_test_thread_routine, NULL, "kgdb_test");
	if (!kthread)
		return -EINVAL;

	wake_up_process(kthread);

	return 0;
}

static void kgdb_test_exit(void)
{
	kthread_stop(kthread);
}

module_init(kgdb_test_init);
module_exit(kgdb_test_exit);
MODULE_LICENSE("GPL");