`default_nettype none

module alu_tb();

`include "params.vh"

reg clk = 1;
reg[31:0] instruction;
reg[31:0] op_a;
reg[31:0] op_b;
wire[31:0] out;

alu dut(
    .instruction(instruction),
    .op_a(op_a),
    .op_b(op_b),
    .out(out)
);

always begin
    #0.5 clk = !clk;
end

initial
  begin
    $dumpfile("alu.vcd");
    $dumpvars;


    // Integer Cumputational Instructions
    // Integer Register-Immediate Instructions
    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_ADDI}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'h0000_0000);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_ADDI}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'h0000_0010);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_ADDI}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'h0000_0000);

    instruction = {{12'b1000_0000_0000}, {5'b0_0000}, {FUNCT3_ADDI}, {OPCODE_OP_IMM}};
    op_a = 32'h8000_0000;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'hffff_f000);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_fffe;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'd1);

    instruction = {{12'b1111_1111_1111}, {5'b0_0000}, {FUNCT3_SLTI}, {OPCODE_OP_IMM}};
    op_a = 32'hffff_ffff;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'd0);

    instruction = {{12'b0000_0000_0001}, {5'b0_0000}, {FUNCT3_SLTI}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0000;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'd1);

    instruction = {{12'b0000_0000_0000}, {5'b0_0000}, {FUNCT3_SLTI}, {OPCODE_OP_IMM}};
    op_a = 32'h0000_0001;
    op_b = 32'hxxxx_xxxx;
    #1
    assert(out == 32'd0);

    $stop;
  end

endmodule
