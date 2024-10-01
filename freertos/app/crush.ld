OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    ram (rwx): ORIGIN = 0x20000000, LENGTH = 0x10000
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*(.start))
        . = 0x100;
        KEEP(*(.text.freertos_risc_v_trap_handler))
        *(.text .text.*)
        *(.rodata .rodata* .srodata .srodata.*)
        . = ALIGN(4);
    } > ram

    .data : {
        . = ALIGN(4);
        __data_start = .;
        *(.data .data.* .sdata .sdata.*);
        . = ALIGN(4);
        __data_end = .;
    } > ram

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

