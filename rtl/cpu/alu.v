`default_nettype none

module alu(
   input wire[31:0] instruction,
   input wire[31:0] op_a,
   input wire[31:0] op_b,
   output reg[31:0] out
);

`include "params.vh"

wire[31:0] I_immediate;
wire[31:0] S_immediate;
wire[31:0] B_immediate;
wire[31:0] U_immediate;
wire[31:0] J_immediate;

inst_immediate_decode immediate_decode(
    .inst(instruction),
    .I_immediate(I_immediate),
    .S_immediate(S_immediate),
    .B_immediate(B_immediate),
    .U_immediate(U_immediate),
    .J_immediate(J_immediate)
);

wire[7] opcode = instruction[6:0];
wire[3] funct3 = instruction[14:12];

always @* begin
    out <= 32'hxxxx_xxxx;

    case(opcode)
    OPCODE_OP_IMM:
        case (funct3)
        FUNCT3_ADDI: out <= op_a + I_immediate;
        FUNCT3_SLTI: out <= op_a < I_immediate;
        endcase
    endcase
end

endmodule
