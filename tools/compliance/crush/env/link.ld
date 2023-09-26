OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

MEMORY
{
    rom (rx): ORIGIN = 0x10000000, LENGTH = 0x200000
    ram (rw): ORIGIN = 0x20000000, LENGTH = 0x4000
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
    } > rom

    .data : {
       . = ALIGN(4);
       _srelocate = .;
       *(.data .data.*);
       . = ALIGN(4);
       _erelocate = .;
    } > ram AT> rom

    _etext = LOADADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        _szero = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ezero = .;
    } > ram
}

