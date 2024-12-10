/*
 * boot.S
 *
 * SPI boot code
 */

#ifndef APP_FLASH_ADDR
#define APP_FLASH_ADDR 0x00100000
#endif

#ifndef APP_SRAM_ADDR
#define APP_SRAM_ADDR 0x10000000
#endif

#ifndef APP_SIZE
#define APP_SIZE 0x10000
#endif

#define SPI_SPSR_RX_CHECK 0x01 /* Check bit 0 is cleared, fifo !empty*/

    /* Registers used
    ra link register
    t1 temp register
    t2 temp register
    s0 Image size
    s1 Load address
    s2 Reset vector
    gp SPI master base address
    a3 get_rx_data return value
    t3 temp register
    */

    .equ    SPI_BASE, 0x50000000
    .equ    SPI_SPCR, 4 * 0x00
    .equ    SPI_SPSR, 4 * 0x01
    .equ    SPI_SPDR, 4 * 0x02
    .equ    SPI_SPER, 4 * 0x03
    .equ    SPI_SPSS, 4 * 0x04

    .section .text.start
    .global _start
_start:
    /* Load SPI base address to gp */
    li gp, SPI_BASE

spi_init:
    /* Clear slave selects */
    sb  zero, SPI_SPSS(gp)

    /* Set clock divider to 4 (arbitrarily chosen value)
    and enable controller */
    addi    t1, zero, 0x40 | 0x01
    sb  t1, SPI_SPCR(gp)

    /* Set appropriate slave select */
    addi    t1, zero, 1
    sb      t1, SPI_SPSS(gp)

    /* Set command to READ at APP_FLASH_ADDR */
    li      a0, ((APP_FLASH_ADDR & 0xFF) <<24) | ((APP_FLASH_ADDR & 0xFF00) << 8) | ((APP_FLASH_ADDR & 0xFF0000) >> 8) | 0x3
    jal     spi_xfer

    /* Get magic word */
    // TODO maybe need this read for this whole thing to work correctly
    // jal  spi_xfer

read_header:
    // TODO do not read a header, use the compile time constant for this configuration
    /* Dummy read two words */
    //jal     spi_xfer
    //jal     spi_xfer

    /* Load image size to s0 */
    //jal     spi_xfer
    //jal     endian_swap
    li  s0, APP_SIZE

    /* Load RAM base address to s1 */
    //jal     spi_xfer
    //jal     endian_swap
    li  s1, APP_SRAM_ADDR

    /* Load reset vector to s2 */
    //jal     spi_xfer
    //jal     endian_swap
    li  s2, APP_SRAM_ADDR

    /* Dummy read rest of header */
    //jal     spi_xfer //dcrc
    //jal     spi_xfer //os, arch, type, comp

    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer
    //jal     spi_xfer

    /* Clear number of copied bytes */
    addi    s4, zero, 0
copy_to_ram:
    jal     spi_xfer

    /* Set memory store address */
    add     t1, s1, s4

    /* Write word to RAM */
    sw  a1, 0(t1)

    /* Increase counter */
    addi    s4, s4, 4

    /* Check if file is completely copied */
    bgt     s0, s4, copy_to_ram

    /* Jump to entry point */
goto_reset:
    jr  s2

    /* Reads ddccbbaa from a1, stores aabbccdd to a2 */
    /*
endian_swap:
    slli    a2, a1, 24   // a2 = aa000000
    srli    t1, a1, 8    // t1 = 00ddccbb
    andi    t1, t1, 0xff // t1 = 000000bb
    slli    t1, t1, 16   // t1 = 00bb0000
    or  a2, a2, t1   // a2 = aabb0000

    srli    t1, a1, 16   // t1 = 0000ddcc
    andi    t1, t1, 0xff // t1 = 000000cc
    slli    t1, t1, 8    // t1 = 0000cc00
    or  a2, a2, t1   // a2 = aabbcc00

    srli    t1, a1, 24   // t1 = 000000dd
    or  a2, a2, t1   // a2 = aabbccdd

    ret
   */ 

spi_xfer:
    /* Loop four times */
    addi    t0, zero, 4

spi_xfer_loop:
    /* Send data in a0[7:0] */
    sb  a0, SPI_SPDR(gp)

spi_xfer_poll:
    /* Wait for data in RX FIFO */
    lbu     t1, SPI_SPSR(gp)
    andi    t1, t1, SPI_SPSR_RX_CHECK
    bnez    t1, spi_xfer_poll

    srli    a1, a1, 8
    lbu     t1, SPI_SPDR(gp)
    slli    t1, t1, 24
    or  a1, a1, t1

    srli    a0, a0, 8
    addi    t0, t0, -1
    bnez    t0, spi_xfer_loop

    ret
