/* Test bench for CSR instructions CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI */

/* Most of the implemented CSRs are not arbitrary read/write registers. Instead
 * they are WARL etc.
 *
 * The most straight forward register to use for testing is the mepc, where
 * every bit other than the last two are always readable and writable.
 * It will also never be written by the system as long as software does not
 * enable interrupts.
 */
`default_nettype none

`include "fatal_assert.vh"

module csr_tb;

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

string test_case_name = "";

reg flash_ack_o = 0;
reg[31:0] flash_dat_o = 32'hzzzz_zzzz;

cpu #(.INITIAL_PC('h1000_0000)) cpu (
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

wire memory_ack_o;
sim_memory #(.BASE_ADDRESS('h2000_0000), .SIZE('h4000)) memory (
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

assign ack_i = flash_ack_o | memory_ack_o;
assign dat_i = flash_dat_o;
integer count = 0;

always begin
    #0.5
    clk <= !clk;
    #0.5
    clk <= !clk;
    count <= count + 1;
end

task static test_case(input string a_test_case_name);
  @(posedge clk)
  reset = 1;
  test_case_name = a_test_case_name;

  @(posedge clk) reset = 0;
endtask


task static LW(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LW}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static LB(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LB}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static LBU(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LBU}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static LH(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LH}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static LHU(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LHU}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static SW(input reg[4:0] rs2, input reg[4:0] rs1, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset[11:5]}, {rs2}, {rs1}, {FUNCT3_SW}, {offset[4:0]}, {OPCODE_STORE}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static SH(input reg[4:0] rs2, input reg[4:0] rs1, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset[11:5]}, {rs2}, {rs1}, {FUNCT3_SH}, {offset[4:0]}, {OPCODE_STORE}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static SB(input reg[4:0] rs2, input reg[4:0] rs1, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset[11:5]}, {rs2}, {rs1}, {FUNCT3_SB}, {offset[4:0]}, {OPCODE_STORE}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

initial begin
    $dumpfile("csr_tb.vcd");
    $dumpvars(0);

    test_case("load word, no offset");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.mem[0] = 32'h0000_0001;

    LW(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    #1
    `fatal_assert (cpu.registers.x1 == 32'h0000_0001);

    test_case("CSSRW");

    `fatal_assert(1 == 2);

    $stop;
end

endmodule
