`default_nettype none

/*
 * Memory intended to be inferred to block ram by the synthesis tool.
 */
module memory_infer #(
    parameter integer BASE_ADDRESS,
    parameter integer SIZE,
    parameter READMEMH_FILE = ""
) (
    input wire clk_i,
    // The memory we are trying to infer can not be reset
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
    output reg rty_o
);
  (* synthesis, ram_block *) reg [31:0] mem[SIZE];

  reg [31:0] data;
  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE);

  // Individal signals so the memory can be observed in VCD output
  genvar i;
  generate
      for(i = 0; i < SIZE && i < 8; i++) begin : g_scope
          wire[31:0] m;
          assign m = mem[i];
      end
  endgenerate

   initial if(READMEMH_FILE != "") $readmemh(READMEMH_FILE, mem);

  wire[31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;
  always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;

    if (stb_i & cyc_i & !ack_o & addressed) begin
      ack_o <= 1;
      if (we_i) begin
        if (sel_i[0]) mem[memory_address][7:0] <= dat_i[7:0];
        if (sel_i[1]) mem[memory_address][15:8] <= dat_i[15:8];
        if (sel_i[2]) mem[memory_address][23:16] <= dat_i[23:16];
        if (sel_i[3]) mem[memory_address][31:24] <= dat_i[31:24];
      end else begin
        data <= mem[memory_address];
      end
    end
  end

endmodule
