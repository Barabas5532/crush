#![no_main]
#![no_std]

use core::panic::PanicInfo;

mod hal;
mod start;

#[panic_handler]
fn panic(_panic: &PanicInfo) -> ! {
    loop {}
}

pub fn main() -> ! {
    let mut blinky_led_on = false;
    loop {
        blinky_led_on = !blinky_led_on;

        let is_pressed = hal::get_button();
        hal::set_led_on(0, blinky_led_on);
        hal::set_led_on(1, is_pressed);
        hal::delay();
    }
}
