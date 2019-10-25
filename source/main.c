#include "system.h"

extern void init_key_irq(void);
extern void init_led(void);
extern void test_led(void);
extern void enable_irq(void);
extern void start_mmu(void);
extern void stop_mmu(void);
extern int arch_mmap(unsigned long vaddr, unsigned long paddr, unsigned long size, unsigned long attr);

int kernel_main(void)
{
    volatile unsigned long *ptr = (volatile unsigned long *)0x30b00000;

    for (; ptr < (volatile unsigned long *)0x30b01000; ptr++)
        *ptr = 0;



    arch_mmap(0x33500000, 0x33a00000, 0x100000, MMU_SECDESC_WB_NCNB);
	arch_mmap(0x33501000, 0x33a01000, 0x100000, MMU_SECDESC_WB_NCNB);
    
    start_mmu();
	
    init_key_irq();
	init_led();
	enable_irq();
    
    *(volatile unsigned int *)0x33500000 = 0x12345678;
    *(volatile unsigned int *)0x33501000 = 0xabcdef00;
    
	while (1)
		test_led();
    
    //return 0;
}
