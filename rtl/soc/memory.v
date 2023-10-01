`default_nettype none

module memory #(
    parameter integer BASE_ADDRESS = 0,
    parameter integer SIZE = 16384
) (
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    input wire [3:0] sel_i,
    input wire [31:0] dat_i,
    output reg [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);
  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE);
  wire [13:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;
  wire [31:0] memory_data;

  memory_ice40_spram ram(
    .clk(clk_i),
    .wen(stb_i & cyc_i & we_i & addressed),
    .wmask(sel_i),
    .addr(memory_address),
    .wdata(dat_i),
    .rdata(memory_data)
  );

  always @(*) begin
      if (ack_o) dat_o <= memory_data;
      else dat_o <= 32'hzzzz_zzzz;
  end

  always @(posedge clk_i) begin
      ack_o <= 0;
      err_o <= 0;
      rty_o <= 0;

      if (stb_i & cyc_i & !ack_o & addressed) begin
        ack_o <= 1;
      end
  end

endmodule
