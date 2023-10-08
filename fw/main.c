
#include <stdbool.h>

#include "hal.h"

int main(void) {
  bool blinky_led_on = false;
  do {
    blinky_led_on = !blinky_led_on;

    bool is_pressed = get_button();

    set_led_on(0, blinky_led_on);
    set_led_on(1, is_pressed);
    delay();
  } while (1);
}

