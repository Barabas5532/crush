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
}

