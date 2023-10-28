//! Start-up code for hardware initialisation.

// FIXME: import bss addresses from linker script

use crate::main;
use core::arch::global_asm;

global_asm!(include_str!("start.S"));

#[no_mangle]
// FIXME: should this be unsafe?
pub extern "C" fn c_start() -> ! {
    // FIXME: bss init

    main();
}
