// SPDX-License-Identifier: GPL-2.0-only

#include <linux/module.h>
#include <linux/delay.h>
#include <linux/kthread.h>

#define DELAY_MSEC	1

static struct task_struct *kthread_cpu[CONFIG_NR_CPUS];

struct task_struct *__kthread_create_on_cpu(int (*threadfn)(void *data),
					    void *data, unsigned int cpu,
					    const char *namefmt)
{
	struct task_struct *p;

	p = kthread_create_on_node(threadfn, data, cpu_to_node(cpu), namefmt,
				   cpu);
	if (IS_ERR(p))
		return p;
	kthread_bind(p, cpu);

	return p;
}

static int thread_routine(void *data)
{
	unsigned long flags;
	
	while(1) {
		local_irq_save(flags);
		mdelay(DELAY_MSEC);
		local_irq_restore(flags);

		usleep_range(1000, 2000);

		if (kthread_should_stop())
			break;
	}

	return 0;
}

static int worker_module_init(void)
{
	int cpu;

	for_each_online_cpu(cpu) {
		kthread_cpu[cpu] = __kthread_create_on_cpu(thread_routine,
							   &kthread_cpu[cpu], cpu,
							   "irqsworker");
		if (!kthread_cpu[cpu])
			return -EINVAL;

		wake_up_process(kthread_cpu[cpu]);
	}

	return 0;
}

static void worked_module_exit(void)
{
	int cpu;

	for (cpu = 0; cpu < CONFIG_NR_CPUS; cpu++) {
		if (kthread_cpu[cpu])
			kthread_stop(kthread_cpu[cpu]);
	}
}

module_init(worker_module_init);
module_exit(worked_module_exit);
MODULE_LICENSE("GPL");