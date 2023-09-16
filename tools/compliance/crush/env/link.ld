OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

MEMORY
{
    rom (rx): ORIGIN = 0x10000000, LENGTH = 32K
    ram (rw): ORIGIN = 0x20000000, LENGTH = 16K
}

SECTIONS
{
    .text : {
        *(.text*)
    } > rom

    .rodata : { *(.rodata*) } > rom

    .bss : { *(.bss*) } > ram
}

