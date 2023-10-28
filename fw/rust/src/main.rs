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
    loop {}
}
