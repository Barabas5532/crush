/*
 * boot.S
 *
 * SPI boot code
 */

#ifndef APP_FLASH_ADDR
#define APP_FLASH_ADDR 0x20000
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

read_header:
    /* Load image size to s0 */
    li  s0, APP_SIZE

    /* Load RAM base address to s1 */
    li  s1, APP_SRAM_ADDR

    /* Load reset vector to s2 */
    li  s2, APP_SRAM_ADDR

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
