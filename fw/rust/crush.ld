OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    mem (rwx): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
}

SECTIONS
{
    .mem : {
        KEEP(*(.start));
        *(.text .text.*);
        *(.rodata .rodata.*);
        *(.bss .bss.*);
        *(.data .data.*);
    } > mem
}

stack_start = ORIGIN(mem) + LENGTH(mem);
