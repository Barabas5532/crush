/* This file implements a test that is able to execute programs stored on the
 * host file system.
 */

`default_nettype none

`timescale 1ns/1ps

module top_freertos_tb;

reg clk;
reg btn_n;
reg btn1;
wire led1;
wire led2;
wire flash_sck;
wire flash_ssb;
wire flash_io0;
wire flash_io1;

top_freertos dut(
    .CLK(clk),
    .BTN_N(btn_n),
    .BTN1(btn1),
    .LED1(led1),
    .LED2(led2),
    .FLASH_SCK(flash_sck),
    .FLASH_SSB(flash_ssb),
    .FLASH_IO0(flash_io0),
    .FLASH_IO1(flash_io1)
);

s25fl128s
 #(.mem_file_name ("crush_freertos.data"),
   .AddrRANGE     (24'h1F_FFFF))
flash
 (
  .SCK     (flash_sck),
  .SI      (flash_io0),
  .CSNeg   (flash_ssb),
  .HOLDNeg (), //Internal pull-up
  .WPNeg   (), //Internal pull-up
  .SO      (flash_io1),
  .RSTNeg (1'b1));

initial begin
    btn_n = 0;
    // Wait for flash to power up
    #500_000 btn_n = 1;
end

initial clk = 0;
always #80 clk <= !clk;

initial btn1 = 0;
always #10_000_000 btn1 <= !btn1;

initial begin
    $dumpfile("top_freertos.vcd");
    $dumpvars(0);

    #(300_000 * 80)

    $display("finishing now");
    $finish;
end

endmodule
