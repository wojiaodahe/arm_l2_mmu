#include "s3c24xx.h"

#define	 GPB5_out	(1<<(5*2))
#define	 GPB6_out	(1<<(6*2))
#define  GPB7_out	(1<<(7*2))
#define	 GPB8_out	(1<<(8*2))


#define	GPB5_msk	(3<<(5*2))
#define	GPB6_msk	(3<<(6*2))
#define	GPB7_msk	(3<<(7*2))
#define	GPB8_msk	(3<<(8*2))


static inline void led_delay(volatile unsigned long dly)
{
    for(; dly > 0; dly--)
	;
}


void init_led()
{
    GPBCON &= ~(GPB5_msk | GPB6_msk | GPB7_msk | GPB8_msk);
    GPBCON |=  (GPB5_out | GPB6_out | GPB7_out | GPB8_out);
}

int test_led(void)
{
	unsigned long i = 0;

	while(1)
	{
		led_delay(0x3f0000);
		GPBDAT = (~(i<<5));	 
		if(++i == 16)
			i = 0;
	}

//	return 0;
}
