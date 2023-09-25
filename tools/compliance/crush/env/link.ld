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
        . = ALIGN(4);
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
    } > rom


    /* TODO set up section push in model header, make simulator save this section
     * to the host
     *
     * For dumping, we can pass the memory array from the RAM module to the
     * simulation control module, then use a memory mapped register to store
     * the start and end offset to dump.
     *
     * Check which sections are actually in the output ELF. Maybe some sections
     * in the linker example are for C, C++ and don't exist here.
     */
/*
    .tohost : {
        _stohost = .;
         *(.tohost)
        _etohost = .;
    } > ram
*/

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

