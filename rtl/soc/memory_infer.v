`default_nettype none

module memory_infer (
    input wire clk,
    input wire wen,
    input wire[3:0] wmask,
    input wire[12:0] addr,
    input wire[31:0] wdata,
    output reg [31:0] rdata
);

  // Each SPRAM is 16K x 16, 256 kbits. This should use two of them to store
  // the low and high part of the data.
  reg [31:0] mem['h4000];

  always @(posedge clk) begin
    rdata <= 32'hxxxx_xxxx;

    if (wen) begin
        if(wmask[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
        if(wmask[1]) mem[addr][15: 8] <= wdata[15: 8];
        if(wmask[2]) mem[addr][23:16] <= wdata[23:16];
        if(wmask[3]) mem[addr][31:24] <= wdata[31:24];
    end else rdata <= mem[addr];
  end
endmodule
