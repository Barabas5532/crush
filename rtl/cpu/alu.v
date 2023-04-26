`default_nettype none

module alu(
   input wire[31:0] instruction,
   input wire[31:0] op_a,
   input wire[31:0] op_b,
   input wire[31:0] out
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

endmodule
