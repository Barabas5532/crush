`default_nettype none

module alu (
    input  wire [31:0] instruction,
    input  wire [31:0] op_a,
    input  wire [31:0] op_b,
    input  wire [31:0] pc,
    output reg  [31:0] out,
    output wire eq,
    output wire neq,
    output wire lt,
    output wire ltu,
    output wire ge,
    output wire geu
);

  `include "params.vh"

  wire [31:0] I_immediate;
  wire [31:0] S_immediate;
  wire [31:0] B_immediate;
  wire [31:0] U_immediate;
  wire [31:0] J_immediate;
  wire [31:0] CSR_immediate;

  inst_immediate_decode immediate_decode (
      .inst(instruction),
      .I_immediate(I_immediate),
      .S_immediate(S_immediate),
      .B_immediate(B_immediate),
      .U_immediate(U_immediate),
      .J_immediate(J_immediate),
      .CSR_immediate(CSR_immediate)
  );

  wire [6:0] opcode = instruction[6:0];
  wire [2:0] funct3 = instruction[14:12];
  wire [4:0] shamt = instruction[24:20];

  assign eq = op_a == op_b;
  assign neq = op_a != op_b;
  assign lt = $signed(op_a) < $signed(op_b);
  assign ltu = op_a < op_b;
  assign ge = $signed(op_a) >= $signed(op_b);
  assign geu = op_a >= op_b;

  always @* begin
    out = 32'hxxxx_xxxx;

    case (opcode)
      OPCODE_OP_IMM:
      case (funct3)
        FUNCT3_ADDI: out = op_a + I_immediate;
        FUNCT3_SLTI: out = $signed(op_a) < $signed(I_immediate);
        FUNCT3_SLTIU: out = op_a < I_immediate;
        FUNCT3_ANDI: out = op_a & I_immediate;
        FUNCT3_ORI: out = op_a | I_immediate;
        FUNCT3_XORI: out = op_a ^ I_immediate;
        FUNCT3_SLLI: out = op_a << shamt;
        // False branch must be signed too for the true branch to actually
        // perform an arithetic shift instead of logical shift...
        FUNCT3_SRLI_SRAI: out = instruction[30] ? $signed(op_a) >>> shamt : $signed(op_a) >> shamt;
      endcase
      OPCODE_OP:
      case (funct3)
        FUNCT3_ADD_SUB: out = instruction[30] ? op_a - op_b : op_a + op_b;
        FUNCT3_SLT: out = $signed(op_a) < $signed(op_b);
        FUNCT3_SLTU: out = op_a < op_b;
        FUNCT3_AND: out = op_a & op_b;
        FUNCT3_OR: out = op_a | op_b;
        FUNCT3_XOR: out = op_a ^ op_b;
        FUNCT3_SLL: out = op_a << op_b[4:0];
        FUNCT3_SRL_SRA:
        out = instruction[30] ? $signed(op_a) >>> op_b[4:0] : $signed(op_a) >> op_b[4:0];
      endcase
      OPCODE_BRANCH: out = pc + B_immediate;
      OPCODE_LUI:    out = U_immediate;
      OPCODE_AUIPC:  out = pc + U_immediate;
      OPCODE_LOAD:   out = op_a + I_immediate;
      OPCODE_STORE:  out = op_a + S_immediate;
      OPCODE_JAL:    out = pc + J_immediate;
      OPCODE_JALR:   out = (op_a + I_immediate) & ~1;
      OPCODE_SYSTEM: case(funct3)
            FUNCT3_CSRRW: out = op_a;
            FUNCT3_CSRRWI: out = CSR_immediate;
            FUNCT3_CSRRC: out = op_a & ~op_b;
            FUNCT3_CSRRCI: out = op_a & ~CSR_immediate;
            FUNCT3_CSRRS: out = op_a | op_b;
            FUNCT3_CSRRSI: out = op_a | CSR_immediate;
      endcase
      default: ;
    endcase
  end

endmodule
