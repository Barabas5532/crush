/* This file implements a test that simulates the CPU configured with interrupts.
 *
 * It is capable of running the FreeRTOS demo app.
 *
 * The initial configuration of the simulation is equivalent to the SoC after it
 * has been booted from flash by the boot ROM. The simulation skips the loading,
 * and starts up with the program already stored in memory.
 */

`default_nettype none

`timescale 1ns/1ps

module cpu_freertos_tb;

`include "params.vh"

reg clk = 1;
reg reset = 1;
wire stb_o;
wire cyc_o;
wire[31:0] adr_o;
wire[3:0] sel_o;
wire[31:0] dat_i;
wire[31:0] dat_o;
wire we_o;
wire ack_i;
wire err_i = 0;
wire rty_i = 0;

wire timer_interrupt;

cpu #(.INITIAL_PC('h1000_0000), .TRAP_PC('h1000_0100)) dut (
    .clk_i(clk),
    .dat_i(dat_i),
    .dat_o(dat_o),
    .rst_i(reset),
    .ack_i(ack_i),
    .err_i(err_i),
    .rty_i(rty_i),
    .stb_o(stb_o),
    .cyc_o(cyc_o),
    .adr_o(adr_o),
    .sel_o(sel_o),
    .we_o(we_o),
    .timer_interrupt(timer_interrupt),
    .external_interrupt(1'b0)
);

wire ram_ack_o;
memory_infer #(.BASE_ADDRESS('h1000_0000), .SIZE('h1_0000)) ram (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(ram_ack_o),
    .err_o(err_i),
    .rty_o(rty_i)
);

initial begin
    string binary_path;
    if($value$plusargs("BINARY_PATH=%s", binary_path)) begin
        integer file;
        integer length;

        $display("Reading ram contents from %s", binary_path);

        file = $fopen(binary_path, "rb");
        length = $fread(ram.mem, file);
        $fclose(file);

        $display("Read %0d bytes", length);
    end else begin
        $error("The BINARY_PATH plus arg must be set");
        $stop;
    end
end

wire mtimer_ack_o;
mtimer #(.BASE_ADDRESS('h3000_0000)) mtimer (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(mtimer_ack_o),
    .err_o(err_i),
    .rty_o(rty_i),
    .interrupt(timer_interrupt)
);

wire gpio_ack_o;
wire gpio_rty_o;
wire gpio_err_o;
wire [5:0] unused;
reg btn = 0;
reg led1;
reg led2;
gpio #(.BASE_ADDRESS('h4000_0000)) gpio (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(gpio_ack_o),
    .err_o(gpio_err_o),
    .rty_o(gpio_rty_o),
    .pin_input({{7{1'b0}}, btn}),
    .pin_output({unused, led2, led1})
);

assign ack_i = ram_ack_o | mtimer_ack_o | gpio_ack_o;

always begin
    #42 clk <= !clk;
end

always begin
    #100_000_000 btn <= !btn;
end

initial begin
    $dumpfile("cpu_freertos_tb.vcd");
    $dumpvars(0);

    #250 reset = 0;
    #50;

    #300_000_000;

    $error("Stop was not called within 300 ms, stopping now");
    $fatal;
end

endmodule
