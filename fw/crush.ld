OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    mem (rwx): ORIGIN = 0x10000000, LENGTH = 0x4000
}

SECTIONS
{
    .mem : {
        . = ALIGN(4);
        KEEP(*(.start))
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
        *(.data .data.*);
    } > mem

    .bss (NOLOAD) : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        bss_end = .;
    } > mem

    .stack : {
        . = 1K; /* stack size */
        /* Calling conventions require 16 byte aligned stack pointer
         * https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-cc.adoc
         */
        . = ALIGN(16);
        stack_start = .;
    } > mem
}

