/* This file implements a test that is able to execute programs stored on the
 * host file system. It can be used along with RISCOF - The RISC-V
 * Compatibility Framework.
 */

`default_nettype none

`timescale 1s/1s

module cpu_tb;

`include "params.vh"

reg clk = 1;
reg reset = 1;

wire        wb_inst_stb_o;
wire        wb_inst_cyc_o;
wire[31:0]  wb_inst_adr_o;
wire[3:0]   wb_inst_sel_o;
wire[31:0]  wb_inst_dat_i;
wire[31:0]  wb_inst_dat_o;
wire        wb_inst_we_o;
wire        wb_inst_ack_i;
wire        wb_inst_err_i = 0;
wire        wb_inst_rty_i = 0;

wire        wb_data_stb_o;
wire        wb_data_cyc_o;
wire[31:0]  wb_data_adr_o;
wire[3:0]   wb_data_sel_o;
wire[31:0]  wb_data_dat_i;
wire[31:0]  wb_data_dat_o;
wire        wb_data_we_o;
wire        wb_data_ack_i;
wire        wb_data_err_i = 0;
wire        wb_data_rty_i = 0;

crush_cpu #(.INITIAL_PC('h1000_0000)) dut (
    .clk_i(clk),
    .rst_i(reset),
    .wb_inst_dat_i(wb_inst_dat_i),
    .wb_inst_dat_o(wb_inst_dat_o),
    .wb_inst_ack_i(wb_inst_ack_i),
    .wb_inst_err_i(wb_inst_err_i),
    .wb_inst_rty_i(wb_inst_rty_i),
    .wb_inst_stb_o(wb_inst_stb_o),
    .wb_inst_cyc_o(wb_inst_cyc_o),
    .wb_inst_adr_o(wb_inst_adr_o),
    .wb_inst_sel_o(wb_inst_sel_o),
    .wb_inst_we_o(wb_inst_we_o),
    .wb_data_dat_i(wb_data_dat_i),
    .wb_data_dat_o(wb_data_dat_o),
    .wb_data_ack_i(wb_data_ack_i),
    .wb_data_err_i(wb_data_err_i),
    .wb_data_rty_i(wb_data_rty_i),
    .wb_data_stb_o(wb_data_stb_o),
    .wb_data_cyc_o(wb_data_cyc_o),
    .wb_data_adr_o(wb_data_adr_o),
    .wb_data_sel_o(wb_data_sel_o),
    .wb_data_we_o(wb_data_we_o)
);

wire wb_inst_flash_ack_o;
memory_infer #(.BASE_ADDRESS('h1000_0000), .SIZE('h20_0000)) flash_emulator (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(wb_inst_stb_o),
    .cyc_i(wb_inst_cyc_o),
    .adr_i(wb_inst_adr_o),
    .sel_i(wb_inst_sel_o),
    .dat_i(wb_inst_dat_o),
    .dat_o(wb_inst_dat_i),
    .we_i(wb_inst_we_o),
    .ack_o(wb_inst_flash_ack_o),
    .err_o(wb_inst_err_i),
    .rty_o(wb_inst_rty_i)
);

initial begin
    string binary_path;
    if($value$plusargs("BINARY_PATH=%s", binary_path)) begin
        integer file;
        integer length;

        $display("Reading flash contents from %s", binary_path);

        file = $fopen(binary_path, "rb");
        length = $fread(flash_emulator.mem, file);
        $fclose(file);

        $display("Read %0d bytes", length);
    end else begin
        $error("The BINARY_PATH plus arg must be set");
        $stop;
    end
end

wire wb_data_init_data_ack_o;
memory_infer #(.BASE_ADDRESS('h2000_0000), .SIZE('h4000)) init_data (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(wb_data_stb_o),
    .cyc_i(wb_data_cyc_o),
    .adr_i(wb_data_adr_o),
    .sel_i(wb_data_sel_o),
    .dat_i(wb_data_dat_o),
    .dat_o(wb_data_dat_i),
    .we_i(wb_data_we_o),
    .ack_o(wb_data_init_data_ack_o),
    .err_o(wb_data_err_i),
    .rty_o(wb_data_rty_i)
);

initial begin
    string path;
    if($value$plusargs("INIT_DATA_PATH=%s", path)) begin
        integer file;
        integer length;

        $display("Reading initialised data memory contents from %s", path);

        file = $fopen(path, "rb");
        length = $fread(init_data.mem, file);
        $fclose(file);

        $display("Read %0d bytes", length);
    end else begin
        $error("The INIT_DATA_PATH plus arg must be set");
        $stop;
    end
end

wire wb_data_memory_ack_o;
memory_infer #(.BASE_ADDRESS('h3000_0000), .SIZE('h4000)) memory (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(wb_data_stb_o),
    .cyc_i(wb_data_cyc_o),
    .adr_i(wb_data_adr_o),
    .sel_i(wb_data_sel_o),
    .dat_i(wb_data_dat_o),
    .dat_o(wb_data_dat_i),
    .we_i(wb_data_we_o),
    .ack_o(wb_data_memory_ack_o),
    .err_o(wb_data_err_i),
    .rty_o(wb_data_rty_i)
);

wire wb_data_control_ack_o;
control #(
    .BASE_ADDRESS('h4000_0000),
    .MEMORY_BASE_ADDRESS('h3000_0000),
    .MEMORY_SIZE('h4000)
) control (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(wb_data_stb_o),
    .cyc_i(wb_data_cyc_o),
    .adr_i(wb_data_adr_o),
    .sel_i(wb_data_sel_o),
    .dat_i(wb_data_dat_o),
    .dat_o(wb_data_dat_i),
    .we_i(wb_data_we_o),
    .ack_o(wb_data_control_ack_o),
    .err_o(wb_data_err_i),
    .rty_o(wb_data_rty_i),
    .memory(memory.mem)
);

assign wb_inst_ack_i = wb_inst_flash_ack_o;
assign wb_data_ack_i = wb_data_init_data_ack_o | wb_data_memory_ack_o | wb_data_control_ack_o;

always begin
    #0.5 clk <= !clk;
end

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0);

    #2.5 reset = 0;
    #0.5

    #300_000

    $error("Stop was not called within 300k clock cycles, stopping now");
    $fatal;
end

endmodule
