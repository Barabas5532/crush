`default_nettype none

module mtimer #(
    parameter integer BASE_ADDRESS = 0
) (
   // wishbone
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
    output reg rty_o,
   // interrupt
   input wire interrupt_enable,
   output reg interrupt
);
   localparam SIZE = 4 * 4;

   reg [63:0] mtime;
   reg [63:0] mtimecmp;

  wire [31:0] address = (adr_i - BASE_ADDRESS);
  wire addressed = (adr_i >= BASE_ADDRESS) && (address < SIZE);
  reg [31:0] data;

   always @(*) begin
      data = 32'hxxxx_xxxx;

      case(address)
        0: begin
           data = mtime[31:0];
        end
        4: begin
           data = mtime[63:32];
        end
        8: begin
           data = mtimecmp[31:0];
        end
        12: begin
           data = mtimecmp[63:32];
        end
      endcase

      if (ack_o & !we_i) dat_o = data;
      else dat_o = 32'hzzzz_zzzz;
   end

   always @(posedge clk_i) begin
      ack_o <= 0;
      err_o <= 0;
      rty_o <= 0;

      if(rst_i) begin
         mtime <= 0;
         mtimecmp <= 0;
      end else begin
         if (stb_i & cyc_i & !ack_o & addressed) begin
            ack_o <= 1;
         end

         mtime <= mtime + 1;

         if(interrupt_enable && mtime == mtimecmp) interrupt <= 1;

         if(mtimecmp > mtime) interrupt <= 0;
      end
   end

endmodule
