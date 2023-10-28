#![no_main]
#![no_std]

use core::panic::PanicInfo;
use core::arch::global_asm;

#[panic_handler]
fn panic(_panic: &PanicInfo) -> ! {
    loop {}
}

pub fn main() -> ! {
    loop {}
}

global_asm!(include_str!("start.S"));

#[no_mangle]
pub extern "C" fn c_start() -> ! {
    main();
}
