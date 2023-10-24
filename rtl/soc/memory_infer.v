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
    output reg [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);

  reg [31:0] mem[SIZE];

  wire [31:0] mask = {{8{sel_i[3]}}, {8{sel_i[2]}}, {8{sel_i[1]}}, {8{sel_i[0]}}};
  wire [31:0] value = mem[memory_address];

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + SIZE);

  integer i;

  wire [31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;

  initial begin : init
    reg[8 * 100] binary_path;
    if ($value$plusargs("BINARY_PATH=%s", binary_path)) begin : has_arg
      integer file;
      integer length;

      $display("Reading memory contents from %s", binary_path);

      file   = $fopen(binary_path, "rb");
      length = $fread(mem, file);
      $fclose(file);

      $display("Read %0d bytes", length);
    end else begin
      $error("The BINARY_PATH plus arg must be set");
      $stop;
    end
  end

  always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    if (stb_i & cyc_i & !ack_o & addressed) begin
      ack_o <= 1;
    end

    if (stb_i & cyc_i & addressed & we_i) begin
     mem[memory_address] <= (value & ~mask) | (dat_i & mask);
    end

    if (stb_i & cyc_i & addressed & !we_i) begin
      dat_o <= mem[memory_address];
    end
  end

endmodule
