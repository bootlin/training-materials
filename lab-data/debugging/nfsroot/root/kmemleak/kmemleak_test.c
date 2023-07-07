// SPDX-License-Identifier: GPL-2.0-only
/*
 * samples/kmemleak/kmemleak-test.c
 *
 * Copyright (C) 2008 ARM Limited
 * Written by Catalin Marinas <catalin.marinas@arm.com>
 */

#define pr_fmt(fmt) "kmemleak: " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/list.h>
#include <linux/percpu.h>
#include <linux/fdtable.h>
#include <linux/workqueue.h>
#include <linux/kmemleak.h>

struct test_node {
	long header[25];
	struct list_head list;
	long footer[25];
};

static LIST_HEAD(test_list);
void *module_data;

static void my_work_func(struct work_struct *unused)
{
	struct test_node *elem;
	int i;
	void *local_data;

	module_data = kmalloc(1024, GFP_KERNEL);
	local_data = kmalloc(1024, GFP_KERNEL);

	for (i = 0; i < 10; i++) {
		elem = kzalloc(sizeof(*elem), GFP_KERNEL);
		pr_info("kzalloc(sizeof(*elem)) = %p\n", elem);
		if (!elem)
			return;
		INIT_LIST_HEAD(&elem->list);
		list_add_tail(&elem->list, &test_list);
	}
}
static DECLARE_WORK(my_work, my_work_func);

static int __init leaky_module_init(void)
{
	schedule_work(&my_work);

	return 0;
}

static void __exit leaky_module_exit(void)
{
	struct test_node *elem, *tmp;

	list_for_each_entry_safe(elem, tmp, &test_list, list)
		list_del(&elem->list);
}

module_init(leaky_module_init);
module_exit(leaky_module_exit);
MODULE_LICENSE("GPL");
