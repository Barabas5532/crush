/* This file implements a test that is able to execute programs stored on the
 * host file system. It can be used along with RISCOF - The RISC-V
 * Compatibility Framework.
 */

`default_nettype none

module cpu_tb;

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

cpu #(.INITIAL_PC('h1000_0000)) dut (
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
    .we_o(we_o)
);

wire flash_ack_o;
flash_emulator #(.BASE_ADDRESS('h1000_0000), .SIZE('h20_0000)) flash_emulator (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(flash_ack_o),
    .err_o(err_i),
    .rty_o(rty_i)
);

wire memory_ack_o;
memory #(.BASE_ADDRESS('h2000_0000)) memory (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(memory_ack_o),
    .err_o(err_i),
    .rty_o(rty_i)
);

  reg [31:0] ram_data['h4000];
  always @* begin
      for(integer i = 0; i < 'h4000; i++) begin
          ram_data[i] = {memory.ram.ram_top.mem[i], memory.ram.ram_bottom.mem[i]};
      end
  end

wire control_ack_o;
control #(
    .BASE_ADDRESS('h3000_0000),
    .MEMORY_BASE_ADDRESS('h2000_0000),
    .MEMORY_SIZE('h4000)
) control (
    .clk_i(clk),
    .rst_i(reset),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(control_ack_o),
    .err_o(err_i),
    .rty_o(rty_i),
    .memory(ram_data)
);

assign ack_i = flash_ack_o | memory_ack_o | control_ack_o;

always begin
    #0.5 clk <= !clk;
end

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0);

    #2.5 reset = 0;
    #0.5

    #200_000

    $error("Stop was not called within 200k clock cycles, stopping now");
    $fatal;
end

endmodule
