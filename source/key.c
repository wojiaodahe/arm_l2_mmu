#include "s3c24xx.h"

#define GPF0_int     (0x2<<(0*2))
#define GPF1_int     (0x2<<(1*2))
#define GPF2_int     (0x2<<(2*2))
#define GPF4_int     (0x2<<(4*2))

#define GPF0_msk    (3<<(0*2))
#define GPF1_msk    (3<<(1*2))
#define GPF2_msk    (3<<(2*2))
#define GPF4_msk    (3<<(4*2))


void init_key_irq(void)
{
   
    GPFCON &= ~(GPF0_msk | GPF1_msk | GPF2_msk | GPF4_msk);
    GPFCON |= GPF0_int | GPF1_int | GPF2_int | GPF4_int;

    EINTMASK &= ~(1<<4);

    PRIORITY = (PRIORITY & ((~0x01) | ~(0x3<<7)));

    INTMSK   &= (~(1<<0)) & (~(1<<1)) & (~(1<<2)) & (~(1<<4));
}
