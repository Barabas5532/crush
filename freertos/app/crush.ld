OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    flash (r): ORIGIN = 0x10000000, LENGTH = 0x8000
    ram (rw): ORIGIN = 0x20000000, LENGTH = 0x8000
    program (rx): ORIGIN = 0x20008000, LENGTH = 0x8000
}

SECTIONS
{
    .program : {
        . = ALIGN(4);
        __program_start = .;
        KEEP(*(.start))
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
        *(.data .data.*);
        __program_end = .;
    } > program AT> flash

    __flash_start = LOADADDR(.program);
    __flash_end = LOADADDR(.program) + LENGTH(.program);

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

