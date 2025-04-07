OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    instruction_memory (x): ORIGIN = 0x00000000, LENGTH = 0x400 * 4
    memory (rw): ORIGIN = 0x10000000, LENGTH = 0x400 * 4
}

SECTIONS
{
    .instruction_memory : {
        . = ALIGN(4);
        KEEP(*(.start))
        *(.text .text.*)
        . = ALIGN(4);
    } > instruction_memory

    .memory : {
        . = ALIGN(4);
        *(.bss .bss.*)
        *(COMMON)
        *(.data .data.*);
        *(.rodata .rodata*)
        . = ALIGN(4);
    } > memory
    
    .stack : {
        . = 1K; /* stack size */
        /* Calling conventions require 16 byte aligned stack pointer
         * https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-cc.adoc
         */
        . = ALIGN(16);
        stack_start = .;
    } > memory
}

