
`default_nettype none

`timescale 1s/1ms

`include "fatal_assert.vh"

module mtimer_tb;

reg clk = 1;
reg reset = 1;
reg stb_o = 0;
reg cyc_o = 0;
reg[31:0] adr_o;
reg[3:0] sel_o;
wire[31:0] dat_i;
reg[31:0] dat_o;
reg we_o;
wire ack_i;
wire err_i;
wire rty_i;

wire interrupt;
reg interrupt_enable = 0;

localparam BASE_ADDRESS = 32'h100;

 
mtimer #(.BASE_ADDRESS(BASE_ADDRESS)) dut (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(ack_i),
    .err_o(err_i),
    .rty_o(rty_i),
    .interrupt_enable(interrupt_enable),
    .interrupt(interrupt)
);

always begin
    #0.5 clk = !clk;
end

// 32-bit write
// Based on Wishbone B4 3.2.3 Classic standard SINGLE WRITE Cycle
task automatic write_register(input reg[31:0] register_address, input reg[31:0] data);
    // Clock edge 0
    `fatal_assert(!ack_i);

    adr_o = register_address;
    dat_o = data;
    we_o = 1'b1;
    sel_o = 4'b1111;

    cyc_o = 1;
    stb_o = 1;

    #1
    // Clock edge 1
    `fatal_assert(ack_i);

    #1
    // Clock edge 2
    stb_o = 0;
    cyc_o = 0;
    #0
    `fatal_assert(!ack_i);
endtask


initial begin
    $dumpfile("mtimer.vcd");
    $dumpvars;

    #0.1

    #1
    reset = 1;

    #1
    reset = 0;

    #5
    write_register(BASE_ADDRESS + 0, 0);

    adr_o = 32'hxxxxxxxx;
    dat_o = 32'hxxxxxxxx;
    sel_o = 4'hx;
    we_o = 1'bx;

    #5
    // 32-bit read from 0
    // Based on Wishbone B4 3.2.1 Classic standard SINGLE READ Cycle
    `fatal_assert(!ack_i);
    adr_o = BASE_ADDRESS + 0;
    we_o = 0;
    sel_o = 4'b1111;
    cyc_o = 1;
    stb_o = 1;

    // Clock edge 0
    #1
    `fatal_assert(ack_i);
    // The clock must have counted since we reset it earlier
    `fatal_assert(dat_i > 32'h0);

    #1
    // Clock edge 2
    stb_o = 0;
    cyc_o = 0;
    #0
    `fatal_assert(!ack_i);

   #5

   // Set mtimecmp to a very large value to ensure interrupt doesn't trigger
   // immediately
   write_register(BASE_ADDRESS + 12, 1);
   #0 interrupt_enable = 1;
   #0 `fatal_assert(!interrupt);
   // mtime = 1000
   write_register(BASE_ADDRESS + 0, 1000);
   // mtimecmp = 1010. Should interrupt in a few cycles
   write_register(BASE_ADDRESS + 8, 1010);
   write_register(BASE_ADDRESS + 12, 0);

   #10
   `fatal_assert(interrupt);

   // mtime = 1000. Should clear interrupt
   write_register(BASE_ADDRESS + 0, 1000);
   `fatal_assert(!interrupt);

    #1
    $stop;
end

endmodule
