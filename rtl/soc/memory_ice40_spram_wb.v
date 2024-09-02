`default_nettype none

/* 32-bit * 16K word (64KByte) memory */
module memory_ice40_spram_wb #(
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

   localparam SIZE = 16384;

  reg [31:0] data;
  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE);

  wire [13:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;

memory_ice40_spram memory(
    .clk(clk_i),
    .rst(rst_i),
    .chip_select(stb_i & cyc_i & !ack_o & addressed),
    .wen(we_i),
    .wmask(sel_i),
    .addr(memory_address),
    .wdata(dat_i),
    .rdata(data));

  always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;

    if (stb_i & cyc_i & !ack_o & addressed) begin
      ack_o <= 1;
    end
  end


endmodule
