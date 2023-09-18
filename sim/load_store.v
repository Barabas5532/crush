/* Test bench for load and store instructions */
`default_nettype none

module load_store;

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
wor ack_i;
wor err_i = 0;
wor rty_i = 0;

string test_case_name = "";

reg flash_ack_o;
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

memory #(.BASE_ADDRESS('h2000_0000), .SIZE('h4000)) memory (
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
    .rty_o(rty_i)
);

assign ack_i = flash_ack_o;
assign dat_i = flash_dat_o;

always begin
    #0.5 clk = !clk;
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
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static LB(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LB}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static LBU(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LBU}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static LH(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LH}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static LHU(input reg[4:0] rs1, input reg[4:0] rd, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset}, {rs1}, {FUNCT3_LHU}, {rd}, {OPCODE_LOAD}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static SW(input reg[4:0] rs2, input reg[4:0] rs1, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset[11:5]}, {rs2}, {rs1}, {FUNCT3_SW}, {offset[4:0]}, {OPCODE_STORE}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

task static SH(input reg[4:0] rs2, input reg[4:0] rs1, input reg[11:0] offset);
    // wait for wishbone instruction read
    @(stb_o & cyc_o);
    @(posedge clk);
    flash_ack_o = 1;
    flash_dat_o = {{offset[11:5]}, {rs2}, {rs1}, {FUNCT3_SH}, {offset[4:0]}, {OPCODE_STORE}};
    @(posedge clk);
    flash_ack_o = 1'bz;
    flash_dat_o = 32'hzzzz_zzzz;
endtask

initial begin
    $dumpfile("load_store.vcd");
    $dumpvars(0);

    test_case("load word, no offset");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0000_0001;

    LW(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0001);

    test_case("load word, with positive offset");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[1] = 32'h0000_0002;

    LW(1, 1, 12'h004);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0002);

    test_case("load word, with negative offset");

    cpu.registers.memory[1] = 32'h2000_0004;
    memory.memory[0] = 32'h0000_0003;

    LW(1, 1, -12'h004);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0003);

    test_case("load byte, negative value");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h8382_8180;

    LB(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'hFFFF_FF80);

    test_case("load byte, positive value");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0302_017F;

    LB(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_007F);

    test_case("load unsigned byte, negative value");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h8382_8180;

    LBU(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0080);

    test_case("load unsigned byte, positive value");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0302_017F;

    LBU(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_007F);

    test_case("load byte, offset 1");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0302_0100;

    LB(1, 1, 12'h001);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0001);

    test_case("load byte, offset 2");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0302_0100;

    LB(1, 1, 12'h002);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0002);

    test_case("load byte, offset 3");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h0302_0100;

    LB(1, 1, 12'h003);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0003);

    test_case("load byte, offset -1");

    cpu.registers.memory[1] = 32'h2000_0004;
    memory.memory[0] = 32'h0302_0100;
    memory.memory[1] = 32'hFFFF_FFFF;

    LB(1, 1, -12'h001);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_0003);

    test_case("load half word");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h8382_8180;

    LH(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'hFFFF_8180);

    test_case("load unsigned half word");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h8382_8180;

    LHU(1, 1, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'h0000_8180);

    test_case("load half word, offset 2");

    cpu.registers.memory[1] = 32'h2000_0000;
    memory.memory[0] = 32'h8382_8180;

    LH(1, 1, 12'h002);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (cpu.registers.x1 == 32'hFFFF_8382);

    test_case("store word");

    cpu.registers.memory[1] = 32'hF3F2_F1F0;
    cpu.registers.memory[2] = 32'h2000_0000;

    SW(1, 2, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (memory.memory[0] == 32'hF3F2_F1F0);

    test_case("store word with offset");

    cpu.registers.memory[1] = 32'hF3F2_F1F0;
    cpu.registers.memory[2] = 32'h2000_0000;

    SW(1, 2, 12'h004);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (memory.memory[1] == 32'hF3F2_F1F0);

    test_case("store half word");

    memory.memory[0] = 32'hDEAD_BEEF;
    cpu.registers.memory[1] = 32'hF3F2_F1F0;
    cpu.registers.memory[2] = 32'h2000_0000;

    SH(1, 2, 12'h000);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (memory.memory[0] == 32'hDEAD_F1F0);

    test_case("store half word with offset");

    memory.memory[0] = 32'hDEAD_BEEF;
    cpu.registers.memory[1] = 32'hF3F2_F1F0;
    cpu.registers.memory[2] = 32'h2000_0000;

    SH(1, 2, 12'h002);
    @(ack_i);
    @(posedge clk);
    @(posedge clk);
    assert (memory.memory[0] == 32'hF1F0_BEEF);

    // store byte
    // store byte, offset 1
    // store byte, offset 2
    // store byte, offset 3

    // TODO misaligned?
    $stop;
end

endmodule
