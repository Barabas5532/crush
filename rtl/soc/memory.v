`default_nettype none

module memory #(
    parameter integer BASE_ADDRESS,
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

  // TODO use primitive for ICE40 SPRAM, or test that this is inferred
  // correctly
  reg [31:0] memory[SIZE];

  wire[31:0] mask = {{8{sel_i[3]}}, {8{sel_i[2]}}, {8{sel_i[1]}}, {8{sel_i[0]}}};
  wire[31:0] value = memory[memory_address];

  // Individal signals so the memory can be observed in VCD output
  genvar i;
  generate
      for(i = 0; i < SIZE && i < 8; i++) begin : g_scope
          wire[31:0] m;
          assign m = memory[i];
      end
  endgenerate

  always @(posedge clk_i) begin
      integer i;
      if(rst_i) begin
        for(i = 0; i < SIZE; i++) begin
            memory[i] = 32'hxxxx_xxxx;
        end
      end
  end

  wire[31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;
  always @(posedge clk_i) begin
    ack_o = 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    if (stb_i & cyc_i & !ack_o & (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE)) begin
      ack_o = 1;
    end

    if (stb_i & cyc_i & ack_o & we_i) begin
     memory[memory_address] <= (value & ~mask) | (dat_i & mask);
    end

    if (stb_i & cyc_i & ack_o & !we_i) begin
      dat_o <= memory[memory_address];
    end
  end

endmodule
