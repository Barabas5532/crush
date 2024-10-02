`default_nettype none

`include "fatal_assert.vh"

module alu_tb ();

  `include "params.vh"

  reg clk = 1;
  reg [31:0] instruction;
  reg [31:0] instruction_le;
  reg [31:0] op_a;
  reg [31:0] op_b;
  reg [31:0] pc = 32'h0000_0000;
  wire [31:0] out;
  wire eq;
  wire neq;
  wire lt;
  wire ltu;
  wire ge;
  wire geu;

  alu dut (
      .instruction(instruction),
      .op_a(op_a),
      .op_b(op_b),
      .pc(pc),
      .out(out),
      .eq(eq),
      .neq(neq),
      .lt(lt),
      .ltu(ltu),
      .ge(ge),
      .geu(geu)
  );

  always begin
    #0.5 clk = !clk;
  end

  assign instruction_le = {
    {instruction[7:0]}, {instruction[15:8]}, {instruction[23:16]}, {instruction[31:24]}
  };

  initial begin
    $dumpfile("alu.vcd");
    $dumpvars;

    // Integer Computational Instructions
    // Integer Register-Immediate Instructions
    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h0000_0000);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h0000_0002);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h0000_0000);

    instruction = {{12'b1000_0000_0000}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h7fff_f800);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_fffe;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_fffe;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTIU}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_ANDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_F80A;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_F802);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_ORI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_000A;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_F80E);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_XORI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_000A;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_F80C);

    instruction = {{7'b000_0000}, {5'b0_0000}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_FFFE);

    instruction = {{7'b000_0000}, {5'b1_1111}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h8000_0000);

    instruction = {{7'b000_0000}, {5'b0_0000}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h7FFF_FFFF);

    instruction = {{7'b000_0000}, {5'b1_1111}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h0000_0001);

    instruction = {{7'b010_0000}, {5'b0_0000}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'h8000_0000);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hC000_0000);

    instruction = {{7'b010_0000}, {5'b1_1111}, {5'b0_0000}, {FUNCT3_SRLI_SRAI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd1;
    op_b = 32'sd3;
    #1 `fatal_assert (out == 32'sd4);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = -32'sd1;
    op_b = 32'sd3;
    #1 `fatal_assert (out == 32'sd2);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = -32'sd3;
    op_b = 32'sd1;
    #1 `fatal_assert (out == -32'sd2);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'h8000_0000;
    op_b = 32'hFFFF_FFFF;
    #1 `fatal_assert (out == 32'h7FFF_FFFF);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd1;
    op_b = 32'sd3;
    #1 `fatal_assert (out == -32'sd2);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = -32'sd1;
    op_b = 32'sd3;
    #1 `fatal_assert (out == -32'sd4);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_ADD_SUB}, {5'b0_0011}, {OPCODE_OP}};
    op_a = -32'sd3;
    op_b = 32'sd1;
    #1 `fatal_assert (out == -32'sd4);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLT}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLT}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLT}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLTU}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1 `fatal_assert (out == 32'd0);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLTU}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLTU}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1 `fatal_assert (out == 32'd1);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_AND}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'h0000_F0F0;
    op_b = 32'h0000_FF00;
    #1 `fatal_assert (out == 32'h0000_F000);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_OR}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'h0000_F0F0;
    op_b = 32'h0000_FF00;
    #1 `fatal_assert (out == 32'h0000_FFF0);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_XOR}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'h0000_F0F0;
    op_b = 32'h0000_FF00;
    #1 `fatal_assert (out == 32'h0000_0FF0);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLL}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFE0;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SLL}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFFF;
    #1 `fatal_assert (out == 32'h8000_0000);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SRL_SRA}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFE0;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SRL_SRA}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFFF;
    #1 `fatal_assert (out == 32'h0000_0001);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SRL_SRA}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFE0;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SRL_SRA}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hFFFF_FFFF;
    #1 `fatal_assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b010_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_SRL_SRA}, {5'b0_0011}, {OPCODE_OP}};
    op_a = 32'h7FFF_FFFF;
    op_b = 32'hFFFF_FFFF;
    #1 `fatal_assert (out == 32'h0000_0000);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BEQ}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'h0000_0001;
    op_b = 32'h0000_0000;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!eq);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BEQ}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'h0000_0001;
    op_b = 32'h0000_0001;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (eq);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BNE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'h0000_0001;
    op_b = 32'h0000_0000;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (neq);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BNE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'h0000_0001;
    op_b = 32'h0000_0001;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!neq);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLT}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!lt);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLT}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = -32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (lt);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLT}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!lt);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLT}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!lt);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLT}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (lt);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLTU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!ltu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLTU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = -32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!ltu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLTU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (ltu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLTU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!ltu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BLTU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (ltu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (ge);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = -32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!ge);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (ge);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (ge);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGE}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!ge);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGEU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (geu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGEU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = -32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (geu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGEU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = -32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!geu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGEU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd1;
    op_b = 32'sd0;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (geu);

    instruction = {{1'b0}, {6'b00_0000}, {5'b0_0001}, {5'b0_0010}, {FUNCT3_BGEU}, {4'b0000}, {1'b0}, {OPCODE_BRANCH}};
    op_a = 32'sd0;
    op_b = 32'sd1;
    #1
    `fatal_assert (out == 32'h0000_0000);
    `fatal_assert (!geu);

    $stop;
  end

endmodule
