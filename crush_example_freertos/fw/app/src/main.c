#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>
#include <timers.h>
#include <semphr.h>

#include <stdbool.h>

#include "hal.h"

static void task( void * parameters );

void main( void )
{
    static StaticTask_t exampleTaskTCB;
    static StackType_t exampleTaskStack[ configMINIMAL_STACK_SIZE ];
    
    ( void ) xTaskCreateStatic( task,
                                "example",
                                configMINIMAL_STACK_SIZE,
                                NULL,
                                configMAX_PRIORITIES - 1U,
                                &( exampleTaskStack[ 0 ] ),
                                &( exampleTaskTCB ) );

    /* Start the scheduler. */
    vTaskStartScheduler();

    for( ; ; )
    {
        /* Should not reach here. */
    }
}

void task(void *parameters)
{
    bool blinky_led_on = false;
    for(;;)
    {
        blinky_led_on = !blinky_led_on;

        bool is_pressed = get_button();

        set_led_on(0, blinky_led_on);
        set_led_on(1, is_pressed);
        delay();
    }
}
