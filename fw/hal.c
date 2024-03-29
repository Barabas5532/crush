#include "hal.h"

// Some random amount of delay. The actual amount will depend on what
// the compiler does. The pragmas are here to make it slightly more
// predictable.
#pragma GCC push_options
#pragma GCC optimize("O0")
void delay()
{
    for(int i = 0; i < 100 * 1000; i++)
    {
        __asm__("nop");
    };
}
#pragma GCC pop_options

#define GPIO_BASE_ADDRESS ((int *)0x40000000)
#define BIT_MASK(n) (1 << (n))

bool get_button(void)
{
    volatile int *gpio = GPIO_BASE_ADDRESS;
    return *gpio & BIT_MASK(8);
}

void set_led_on(int index, bool led_on)
{
    volatile int *gpio = GPIO_BASE_ADDRESS;
    if(led_on)
    {
        *gpio |= BIT_MASK(index);
    }
    else
    {
        *gpio &= ~BIT_MASK(index);
    }
}
