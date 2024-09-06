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
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o,
   // interrupt
   input wire interrupt_enable,
   output reg interrupt
);
   // The number of 32-bit registers that can be addressed inside this
   // peripheral
   localparam SIZE = 4;

  wire [31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;
  wire addressed = (adr_i >= BASE_ADDRESS) && (memory_address < SIZE);

   /* Implemented as registers to simplify the wishbone interface implementation.
    *
    * It would cleaner to define some kind of bidirectional alias so that we can
    * read and write either the 32-bit register representation or the 64-bit
    * counter representation, but it doesn't seem to be possible. We can at
    * least read from the 64-bit representation below, but we must write to the
    * 32-bit representation.
    */
   reg [31:0] mem [4];

   wire [63:0] mtime;
   assign mtime = {mem[1], mem[0]};

   wire [63:0] mtimecmp;
   assign mtimecmp = {mem[3], mem[2]};

  reg [31:0] data;
  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

   always @(posedge clk_i) begin
      ack_o <= 0;
      err_o <= 0;
      rty_o <= 0;

      if(rst_i) begin
         for(int i = 0; i < 4; i++) mem[i] <= 0;
         interrupt <= 0;
      end else begin
         {mem[1], mem[0]} <= mtime + 1;

         // wishbone access overwrites counting behaviour
         if (stb_i & cyc_i & !ack_o & addressed) begin
            ack_o <= 1;
        if(we_i) begin
        if (sel_i[0]) mem[memory_address][7:0] <= dat_i[7:0];
        if (sel_i[1]) mem[memory_address][15:8] <= dat_i[15:8];
        if (sel_i[2]) mem[memory_address][23:16] <= dat_i[23:16];
        if (sel_i[3]) mem[memory_address][31:24] <= dat_i[31:24];
            end else begin
               data <= mem[memory_address];
            end
         end

         if(interrupt_enable && mtime == mtimecmp) interrupt <= 1;
         if(mtimecmp > mtime) interrupt <= 0;
      end
   end

endmodule
