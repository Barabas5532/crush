`default_nettype none

module alu_tb ();

  `include "params.vh"

  reg clk = 1;
  reg [31:0] instruction;
  reg [31:0] instruction_le;
  reg [31:0] op_a;
  reg [31:0] op_b;
  wire [31:0] out;

  alu dut (
      .instruction(instruction),
      .op_a(op_a),
      .op_b(op_b),
      .out(out)
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
    #1 assert (out == 32'h0000_0000);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'h0000_0002);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'h0000_0000);

    instruction = {{12'b1000_0000_0000}, {5'b0_0000}, {FUNCT3_ADDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'h7fff_f800);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_fffe;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'd0);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'd1);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'd0);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_ANDI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_F80A;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'hFFFF_F802);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_ORI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_000A;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'hFFFF_F80E);

    instruction = {{12'b1000_0000_0110}, {5'b0_0000}, {FUNCT3_XORI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_000A;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'hFFFF_F80C);

    instruction = {{7'b000_0000}, {5'b0_0000}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'hFFFF_FFFF);

    instruction = {{7'b000_0000}, {5'b0_0001}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'hFFFF_FFFE);

    instruction = {{7'b000_0000}, {5'b1_1111}, {5'b0_0000}, {FUNCT3_SLLI}, {5'b0_0001}, {OPCODE_OP_IMM}};
    op_a = 32'hFFFF_FFFF;
    op_b = 32'hxxxx_xxxx;
    #1 assert (out == 32'h8000_0000);

    $stop;
  end

endmodule
