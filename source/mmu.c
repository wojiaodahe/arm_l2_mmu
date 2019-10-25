#include "system.h"


#define L1_BASE 0x30a00000
#define L2_BASE 0x30b00000

#define COARSE_PAGE                         0x02
#define L2_DESC_FULL_ACCESS                 0xff0
#define L2_DESC_OFFSET_MASK                 0xff000
#define L2_DESC_NCNB                        0x00
#define L2_DESC_CB                          ((1 << 2) | (1 << 3))
#define L2_DESC_CNB                         (1 << 3)
#define L2_DESC_SET_DOMAIN(vaddr, domain)   ((vaddr) |= (((domain) & 0xf) << 5))
#define L2_DESC_OFFSET_IN_SEC(vaddr)        (((vaddr) & L2_DESC_OFFSET_MASK) >> 12)

inline void set_l1_desc(unsigned long l1_base, unsigned long vaddr, unsigned long desc)
{
    volatile unsigned long *ptr = (volatile unsigned long *)l1_base;

    *(ptr + (vaddr >> 20)) = desc;
}

inline void set_l2_desc(unsigned long l2_base, unsigned long vaddr, unsigned long paddr)
{
    volatile unsigned long *ptr;

    ptr = (volatile unsigned long *)l2_base;
    ptr += (vaddr & 0xff000) >> 12;
    *ptr = paddr;
}

inline int arch_mmap(unsigned long vaddr, unsigned long paddr, unsigned long size, unsigned long attr)
{
    set_l2_desc(L2_BASE, vaddr, paddr | 0xff0 | 1 << 2 | 1 <<3 | 0x02);
    set_l1_desc(L1_BASE, vaddr, L2_BASE | (3 << 5) | 0x01);

    return 0;
}
