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

task static reset_registers();
  integer i;
  for (i = 0; i < 32; i++) begin
    cpu.registers.memory[i] = 32'hxxxx_xxxx;
  end
endtask

task static test_case(input string a_test_case_name);
  @(posedge clk)
  reset = 1;
  reset_registers;

  test_case_name = a_test_case_name;

  @(posedge clk) reset = 0;
endtask

task static CSRRW(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] rs1);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {rs1}, {FUNCT3_CSRRW}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static CSRRS(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] rs1);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {rs1}, {FUNCT3_CSRRS}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static CSRRC(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] rs1);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {rs1}, {FUNCT3_CSRRC}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static CSRRWI(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] imm);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {imm}, {FUNCT3_CSRRWI}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static CSRRSI(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] imm);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {imm}, {FUNCT3_CSRRSI}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

task static CSRRCI(input reg[4:0] rd, input reg[11:0] csr, input reg[4:0] imm);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{csr}, {imm}, {FUNCT3_CSRRCI}, {rd}, {OPCODE_SYSTEM}};
    @(posedge clk);
    flash_ack_o = 0;
    flash_dat_o = 32'hzzzz_zzzz;
    #0;
endtask

initial begin
    $dumpfile("csr_tb.vcd");
    $dumpvars(0);

    test_case("CSRRW");

    cpu.registers.memory[1] = 32'h0000_00A0;
    cpu.registers.memory[2] = 32'h0000_00B0;

    CSRRW(1, CSR_MEPC, 2);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h0000_0000);
    `fatal_assert (cpu.mepc == 32'h0000_00B0);

    CSRRW(1, CSR_MEPC, 2);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h0000_00B0);
    `fatal_assert (cpu.mepc == 32'h0000_00B0);
    #1;

    test_case("CSRRS");

    cpu.mepc                = 32'h1010_0000;
    cpu.registers.memory[2] = 32'h1100_0000;

    CSRRS(1, CSR_MEPC, 2);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h1010_0000);
    `fatal_assert (cpu.mepc         == 32'h1110_0000);
    #1;

    test_case("CSRRC");

    cpu.mepc                = 32'h1010_0000;
    cpu.registers.memory[2] = 32'h1100_0000;

    CSRRC(1, CSR_MEPC, 2);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h1010_0000);
    `fatal_assert (cpu.mepc         == 32'h0010_0000);
    #1;

    test_case("CSRRWI");

    cpu.mepc = 32'h0000_0014;

    CSRRWI(1, CSR_MEPC, 5'h18);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h0000_0014);
    `fatal_assert (cpu.mepc         == 32'h0000_0018);
    #1;

    test_case("CSRRSI");

    cpu.mepc = 32'h0000_0014;

    CSRRSI(1, CSR_MEPC, 5'h18);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h0000_0014);
    `fatal_assert (cpu.mepc         == 32'h0000_001C);
    #1;

    test_case("CSRRCI");

    cpu.mepc = 32'h0000_0014;

    CSRRCI(1, CSR_MEPC, 5'h18);

    #1;
    @(cpu.state == cpu.STATE_FETCH);
    `fatal_assert (cpu.registers.x1 == 32'h0000_0014);
    `fatal_assert (cpu.mepc         == 32'h0000_0004);
    #1;

    $stop;
end

endmodule
