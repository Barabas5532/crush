use core::arch::asm;

pub(crate) fn delay() {
    for _ in 0..10 {
        unsafe {
            asm!("nop");
        }
    }
}

const GPIO_BASE_ADDRESS: *mut u32 = 0x40000000 as *mut u32;

const fn bit_mask(i: u32) -> u32 {
    1 << i
}

pub(crate) fn get_button() -> bool {
    unsafe {
        return (GPIO_BASE_ADDRESS.read_volatile() & bit_mask(8)) != 0;
    }
}

pub(crate) fn set_led_on(index: u32, led_on: bool) {
    if led_on {
        unsafe {
            let value = GPIO_BASE_ADDRESS.read_volatile();
            GPIO_BASE_ADDRESS.write_volatile(value | bit_mask(index));
        }
    } else {
        unsafe {
            let value = GPIO_BASE_ADDRESS.read_volatile();
            GPIO_BASE_ADDRESS.write_volatile(value & !bit_mask(index));
        }
    }
}
