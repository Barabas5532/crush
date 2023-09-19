`default_nettype none

module alu (
    input  wire [31:0] instruction,
    input  wire [31:0] op_a,
    input  wire [31:0] op_b,
    input  wire [31:0] pc,
    output reg  [31:0] out
);

  `include "params.vh"

  wire [31:0] I_immediate;
  wire [31:0] S_immediate;
  wire [31:0] B_immediate;
  wire [31:0] U_immediate;
  wire [31:0] J_immediate;

  inst_immediate_decode immediate_decode (
      .inst(instruction),
      .I_immediate(I_immediate),
      .S_immediate(S_immediate),
      .B_immediate(B_immediate),
      .U_immediate(U_immediate),
      .J_immediate(J_immediate)
  );

  wire [6:0] opcode = instruction[6:0];
  wire [2:0] funct3 = instruction[14:12];
  wire [4:0] shamt = instruction[24:20];

  always @* begin
    out <= 32'hxxxx_xxxx;

    case (opcode)
      OPCODE_OP_IMM:
      case (funct3)
        FUNCT3_ADDI: out <= op_a + I_immediate;
        FUNCT3_SLTI: out <= $signed(op_a) < $signed(I_immediate);
        FUNCT3_SLTIU: out <= op_a < I_immediate;
        FUNCT3_ANDI: out <= op_a & I_immediate;
        FUNCT3_ORI: out <= op_a | I_immediate;
        FUNCT3_XORI: out <= op_a ^ I_immediate;
        FUNCT3_SLLI: out <= op_a << shamt;
        // False branch must be signed too for the true branch to actually
        // perform an arithetic shift instead of logical shift...
        FUNCT3_SRLI_SRAI: out <= instruction[30] ? $signed(op_a) >>> shamt : $signed(op_a) >> shamt;
      endcase
      OPCODE_OP:
      case (funct3)
        FUNCT3_ADD_SUB: out <= instruction[30] ? op_a - op_b : op_a + op_b;
        FUNCT3_SLT: out <= $signed(op_a) < $signed(op_b);
        FUNCT3_SLTU: out <= op_a < op_b;
        FUNCT3_AND: out <= op_a & op_b;
        FUNCT3_OR: out <= op_a | op_b;
        FUNCT3_XOR: out <= op_a ^ op_b;
        FUNCT3_SLL: out <= op_a << op_b[4:0];
        FUNCT3_SRL_SRA:
        out <= instruction[30] ? $signed(op_a) >>> op_b[4:0] : $signed(op_a) >> op_b[4:0];
      endcase
      OPCODE_BRANCH:
      case (funct3)
        FUNCT3_BEQ:  out <= op_a == op_b;
        FUNCT3_BNE:  out <= op_a != op_b;
        FUNCT3_BLT:  out <= $signed(op_a) < $signed(op_b);
        FUNCT3_BLTU: out <= op_a < op_b;
        FUNCT3_BGE:  out <= $signed(op_a) >= $signed(op_b);
        FUNCT3_BGEU: out <= op_a >= op_b;
      endcase
      OPCODE_LUI:   out <= U_immediate;
      OPCODE_AUIPC: out <= pc + U_immediate;
      OPCODE_LOAD:  out <= op_a + I_immediate;
      OPCODE_STORE: out <= op_a + S_immediate;
      OPCODE_JAL:   out <= pc + J_immediate;
      OPCODE_JALR:  out <= (op_a + I_immediate) & ~1;
    endcase
  end

endmodule
