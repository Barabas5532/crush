OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    rom (rx): ORIGIN = 0x00000000, LENGTH = 256
}

SECTIONS
{
    .rom : {
        . = ALIGN(4);
        KEEP(*(.text.start))
        *(.text .text.*)
    } > rom
}

