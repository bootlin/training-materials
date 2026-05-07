#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Useful general-purpose kernel APIs

===  Memory/string utilities

- In #kfile("include/linux/string.h")

  - Memory-related: #kfunc("memset"), #kfunc("memcpy"),
    #kfunc("memmove"), #kfunc("memscan"), #kfunc("memcmp"),
    #kfunc("memchr")

  - String-related: #kfunc("strcpy"), #kfunc("strcat"),
    #kfunc("strcmp"), #kfunc("strchr"), #kfunc("strrchr"),
    #kfunc("strlen") and variants

  - Allocate and copy a string: #kfunc("kstrdup"),
    #kfunc("kstrndup")

  - Allocate and copy a memory area: #kfunc("kmemdup")

- In #kfile("include/linux/kernel.h")

  - String to int conversion: #kfunc("simple_strtoul"),
    #kfunc("simple_strtol"), #kfunc("simple_strtoull"),
    #kfunc("simple_strtoll")

  - Other string functions: #kfunc("sprintf"), #kfunc("sscanf")

===  Linked lists

- Convenient linked-list facility in #kfile("include/linux/list.h")

  - Used in thousands of places in the kernel

- Add a #kstruct("list_head") member to the structure whose
  instances will be part of the linked list. It is usually named `node`
  when each instance needs to only be part of a single list.

- Define the list with the #kfunc("LIST_HEAD") macro for a global
  list, or define a #kstruct("list_head") element and initialize it
  with #kfunc("INIT_LIST_HEAD") for lists embedded in a structure.

- Then use the `list_*()` API to manipulate the list

  - Add elements: #kfunc("list_add"), #kfunc("list_add_tail")

  - Remove, move or replace elements: #kfunc("list_del"),
    #kfunc("list_move"), #kfunc("list_move_tail"),
    #kfunc("list_replace")

  - Test the list: #kfunc("list_empty")

  - Iterate over the list: `list_for_each_*()` family of macros

===  Linked lists examples 1/2

#text(size: 16pt)[#kfile("drivers/i2c/busses/i2c-stm32f7.c")]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
```c
/**
 * struct stm32f7_i2c_timings - private I2C output parameters
 * @node: List entry
 * @presc: Prescaler value
 * @scldel: Data setup time
 * @sdadel: Data hold time
 * @sclh: SCL high period (master mode)
 * @scll: SCL low period (master mode)
 */
struct stm32f7_i2c_timings {
  struct list_head node;
  u8 presc;
  u8 scldel;
  u8 sdadel;
  u8 sclh;
  u8 scll;
};
```]

===  Linked lists examples 2/2

#text(size: 16pt)[#kfile("drivers/i2c/busses/i2c-stm32f7.c")]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
```c
static int stm32f7_i2c_compute_timing(/* ... */)
{
  struct stm32f7_i2c_timings *v;
  struct list_head solutions;
  INIT_LIST_HEAD(&solutions);
  /* ... */

  for (p = 0; p < STM32F7_PRESC_MAX; p++) {
    for (l = 0; l < STM32F7_SCLDEL_MAX; l++) {
      v = kmalloc(sizeof(*v), GFP_KERNEL);
      v->presc = p;
      v->scldel = l;
      list_add_tail(&v->node, &solutions);
    }
  }

  list_for_each_entry(v, &solutions, node) {
    /* ... */
  }
}
```]