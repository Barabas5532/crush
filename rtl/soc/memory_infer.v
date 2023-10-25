`default_nettype none

/*
 * Memory intended to be inferred to block ram by the synthesis tool.
 */
module memory_infer #(
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
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);

  (* synthesis, ram_block *)reg [31:0] mem  [SIZE];

  reg [31:0] data;
  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE);

  wire [31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;

  initial $readmemh("fw.data", mem);

  always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;

    // Binaries output by gcc are always in little endian order. Our
    // wishbone is in big endian order. Swap the endianness so the program can
    // be read correctly.
    if (stb_i & cyc_i & !ack_o & addressed) begin
      ack_o <= 1;
      if (we_i) begin
        if (sel_i[3]) mem[memory_address][31:24] <= dat_i[7:0];
        if (sel_i[2]) mem[memory_address][23:16] <= dat_i[15:8];
        if (sel_i[1]) mem[memory_address][15:8] <= dat_i[23:16];
        if (sel_i[0]) mem[memory_address][7:0] <= dat_i[31:24];
      end else begin
        data <= {
          {mem[memory_address][7:0]},
          {mem[memory_address][15:8]},
          {mem[memory_address][23:16]},
          {mem[memory_address][31:24]}
        };
      end
    end
  end

endmodule
