OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    mem (rwx): ORIGIN = 0x00000000, LENGTH = 0x800 * 4
}

SECTIONS
{
    .mem : {
        KEEP(*(.blah));
        *(.text .text.*);
        *(.rodata .rodata.*);
        *(.bss .bss.*);
        *(.data .data.*);
    } > mem
}

stack_start = ORIGIN(mem) + LENGTH(mem);
