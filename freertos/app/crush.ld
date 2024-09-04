OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    flash (rx): ORIGIN = 0x10000000, LENGTH = 0x10000
    ram (rwx): ORIGIN = 0x20000000, LENGTH = 0x10000
}

SECTIONS
{
    .flash : {
        . = ALIGN(4);
        KEEP(*(.start))
        *(.text .text.*)
        *(.rodata .rodata* .srodata .srodata.*)
        . = ALIGN(4);
    } > flash

    .data : {
        . = ALIGN(4);
        __data_start = .;
        *(.data .data.* .sdata .sdata.*);
        . = ALIGN(4);
        __data_end = .;
    } > ram AT> flash

    __flash_data_start = LOADADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss .bss.* .sbss .sbss.*)
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

