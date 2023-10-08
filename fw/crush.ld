OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    /* TODO review the */
    rom (rx): ORIGIN = 0x10000000, LENGTH = 0x1e000
    ram (rw): ORIGIN = 0x20000000, LENGTH = 0x4000
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*(.start))
        *(.text .text.*)
        *(.rodata .rodata*)
        . = ALIGN(4);
    } > rom

    .data : {
       . = ALIGN(4);
       data_ram_start = .;
       *(.data .data.*);
       . = ALIGN(4);
       data_ram_end = .;
    } > ram AT> rom

    data_flash_start = LOADADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        bss_end = .;
    } > ram
}

