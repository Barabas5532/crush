`default_nettype none

/* 32-bit * 16K word (64KByte) memory */
module flash #(
    parameter integer BASE_ADDRESS = 0
) (
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    input wire [3:0] sel_i,
    input wire [31:0] dat_i,
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);


// TODO: connect to the hard SPI controller
// Probably need a reset output signal that prevents the SoC booting while the
// SPI hardware is initialised.


endmodule
