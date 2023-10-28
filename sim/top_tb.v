/* This file implements a test that is able to execute programs stored on the
 * host file system.
 */

`default_nettype none

`timescale 1ns/1ns

module top_tb;

reg clk;
reg btn_n;
reg btn1;
wire led1;
wire led2;

top top(
    .CLK(clk),
    .BTN_N(btn_n),
    .BTN1(btn1),
    .LED1(led1),
    .LED2(led2)
);

initial begin
    btn_n = 0;
    #400 btn_n = 1;
end

initial clk = 0;
always #80 clk <= !clk;

initial btn1 = 0;
always #10_000_000 btn1 <= !btn1;

initial begin
    $dumpfile("top.vcd");
    $dumpvars(0);

    #(300_000 * 80)

    $display("finishing now");
    $finish;
end

endmodule
