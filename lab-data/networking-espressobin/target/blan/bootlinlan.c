// SPDX-License-Identifier: GPL-2.0
#include <linux/etherdevice.h>
#include <linux/init.h>
#include <linux/module.h>
#include <net/rtnetlink.h>

/* MUST mirror exactly what iproute2 does. Normally, this would go under
 * include/uapi/linux/if_link.h
 */
enum {
	IFLA_BLAN_UNSPEC,
	IFLA_BLAN_ID,
	__IFLA_BLAN_MAX,
};

#define IFLA_BLAN_MAX (__IFLA_BLAN_MAX - 1)

#define ETH_P_BLAN	0x424C	/* "BL" */

struct blan_tag {
	__be16 etype;
	__be16 id;
} __packed;


static int __init bootlinlan_init(void)
{
	/* TODO */
	return 0;
}


static void __exit bootlinlan_exit(void)
{
	/* TODO */
}

module_init(bootlinlan_init);
module_exit(bootlinlan_exit);
MODULE_LICENSE("GPL");
