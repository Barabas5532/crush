`default_nettype none

module spi #(
    parameter integer BASE_ADDRESS
) (
    input wire clk_i,
    // verilator lint_off UNUSEDSIGNAL
    input wire rst_i,
    // verilator lint_on UNUSEDSIGNAL
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    input wire [3:0] sel_i,
    input wire [31:0] dat_i,
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o,
    // Flash SPI interface
    inout wire flash_clk,
    inout wire flash_miso,
    inout wire flash_mosi,
    output wire flash_cs_n
);
  reg[7:0] spi_dat_o;
  wire [31:0] data = {24'h0, spi_dat_o};

  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + 4 * 32'h10);
  wire[31:0] address = adr_i - BASE_ADDRESS;

  // Interrupt output is ignored. The CPU is programmed to send commands slow
  // enough that we will not overflow the FIFOs without using the interrupt.
  simple_spi spi (
      // Wishbone
      .clk_i  (clk_i),
      .rst_i  (rst_i),
      .adr_i  (address[9-:8]),
      .dat_i  (dat_i[7:0]),
      .we_i   (we_i),
      .cyc_i  (addressed & cyc_i),
      .stb_i  (addressed & stb_i),
      .dat_o  (spi_dat_o),
      .ack_o  (ack_o),
      // SPI flash chip
      .sck_o  (flash_clk),
      .ss_o   (flash_cs_n),
      .mosi_o (flash_mosi),
      .miso_i (flash_miso)
  );

  assign err_o = 0;
  assign rty_o = 0;

endmodule
