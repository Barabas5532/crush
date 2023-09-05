/* This file implements a test that is able to execute programs stored on the
 * host file system. It can be used along with RISCOF - The RISC-V
 * Compatibility Framework.
 *
 * TODO
 * - Fake system:
 * - Wishbone slave that reads binary from file
 * - wishbone RAM
 * - wishbone peripheral to terminate execution when accessed (check riscof
 *   requirements)
 * using https://steveicarus.github.io/iverilog/usage/vpi.html maybe
 * - Can fusesoc be configured to run the sim with the binary? Maybe call vvp
 *   manually in the riscof config after getting fusesoc to build it.
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
reg[31:0] dat_i;
wire[31:0] dat_o;
wire we_o;
reg ack_i = 0;
reg err_i = 0;
reg rty_i = 0;

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

flash #(.BASE_ADDRESS('h1000_0000), .SIZE('h4000)) flash (
    .clk_i(clk),
    .dat_i(dat_o),
    .dat_o(dat_i),
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

memory #(.BASE_ADDRESS('h2000_0000), .SIZE('h4000)) memory (
    .clk_i(clk),
    .dat_i(dat_o),
    .dat_o(dat_i),
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

always begin
    #0.5 clk = !clk;
end

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars;

    #0.1
    #1 reset = 0;
    #1

    #1
    assert(cyc_o == 1'b1);
    assert(stb_o == 1'b1);
    assert(sel_o == 4'b1111);
    // ADDI r1, r0, 1
    //            imm     rs1         funct3      rd          opcode
    dat_i = {{12'h001}, {5'h0}, {FUNCT3_ADDI}, {5'h1}, OPCODE_OP_IMM};
    ack_i = 1;

    #1
    ack_i = 0;
    dat_i = 32'hxxxx_xxxx;
    assert(cyc_o == 0);
    assert(stb_o == 0);

    #4 assert(dut.registers.memory[1] == 1);

    #10 $stop;
end

endmodule
