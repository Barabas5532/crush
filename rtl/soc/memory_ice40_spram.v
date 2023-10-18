`default_nettype none

module memory_ice40_spram (
    input wire clk,
    input wire rst,
    input wire wen,
    input wire[3:0] wmask,
    input wire[13:0] addr,
    input wire[31:0] wdata,
    output reg [31:0] rdata
);

  SB_SPRAM256KA ram_top(
    .DATAIN(wdata[31:16]),
    .ADDRESS(addr),
    .MASKWREN({{2{wmask[3]}}, {2{wmask[2]}}}),
    .WREN(wen),
    .CHIPSELECT(1'b1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(!rst),
    .DATAOUT(rdata[31:16])
  );

  SB_SPRAM256KA ram_bottom(
    .DATAIN(wdata[15:0]),
    .ADDRESS(addr),
    .MASKWREN({{2{wmask[1]}}, {2{wmask[0]}}}),
    .WREN(wen),
    .CHIPSELECT(1'b1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(!rst),
    .DATAOUT(rdata[15:0])
  );

endmodule
