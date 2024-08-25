OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    ram (rwx): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
    
    /* TODO move firmware to the flash, set up load from flash to program memory */
    /*
     * TODO would be even better if we move the RAM to SPRAM too next to the
     * firmware and stop using blockram.
     */
     /*
    ram (rw): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
    program (rx): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
    flash (r): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
     */
}

SECTIONS
{
    /* TODO move firmware to the program memory, set up load from flash to program memory */
    .ram : {
        . = ALIGN(4);
        KEEP(*(.start))
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
        *(.data .data.*);
    } > ram

    .bss (NOLOAD) : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        bss_end = .;
    } > ram

    /* Calling conventions require 16 byte aligned stack pointer
     * https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-cc.adoc
     *
     * This is initially the entry point stack, then is reused as the FreeRTOS
     * interrupt stack when the scheduler starts.
     */
    .stack : ALIGN(16) {
        . = 1K; /* stack size */
        stack_start = .;
        __freertos_irq_stack_top = .;
    } > ram
}

