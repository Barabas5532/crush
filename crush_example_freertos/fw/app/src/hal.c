#include "hal.h"
#include "FreeRTOS.h"
#include "task.h"

void delay()
{
    vTaskDelay(pdMS_TO_TICKS(1000));
}

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
