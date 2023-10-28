OUTPUT_ARCH( "riscv" )
ENTRY(start)

MEMORY
{
    mem (rwx): ORIGIN = 0x10000000, LENGTH = 0x800 * 4
}

SECTIONS
{
    .mem : {
        . = ALIGN(4);
        /* FIXME: must use ".init" due to possible bug in rust:
         * https://github.com/rust-lang/rust/issues/117323
         */
        KEEP(*(.init));
        *(.text .text.*);
        *(.rodata .rodata*);
        . = ALIGN(4);
        *(.data .data.*);
    } > mem

    .bss (NOLOAD) : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss .bss.*);
        . = ALIGN(4);
        bss_end = .;
    } > mem

    stack_start = ORIGIN(mem) + LENGTH(mem);
}

