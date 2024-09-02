// vim:syntax=verilog:

// Based on RV32I Base Instruction Set table from
// The RISC-V Instruction Set Manual
// Volume I: Unprivileged ISA
// Document Version 20191213
// Chapter 24

// verilator lint_off UNUSEDPARAM
localparam OPCODE_OP_IMM   = 7'b0010011;
localparam OPCODE_LUI      = 7'b0110111;
localparam OPCODE_AUIPC    = 7'b0010111;
localparam OPCODE_OP       = 7'b0110011;
localparam OPCODE_JAL      = 7'b1101111;
localparam OPCODE_JALR     = 7'b1100111;
localparam OPCODE_BRANCH   = 7'b1100011;
localparam OPCODE_LOAD     = 7'b0000011;
localparam OPCODE_STORE    = 7'b0100011;
localparam OPCODE_MISC_MEM = 7'b0100011;
localparam OPCODE_SYSTEM   = 7'b1110011;

localparam FUNCT3_BEQ   = 3'b000;
localparam FUNCT3_BNE   = 3'b001;
localparam FUNCT3_BLT   = 3'b100;
localparam FUNCT3_BGE   = 3'b101;
localparam FUNCT3_LB    = 3'b000;
localparam FUNCT3_LH    = 3'b001;
localparam FUNCT3_LW    = 3'b010;
localparam FUNCT3_LBU   = 3'b100;
localparam FUNCT3_LHU   = 3'b101;
localparam FUNCT3_SB    = 3'b000;
localparam FUNCT3_SH    = 3'b001;
localparam FUNCT3_SW    = 3'b010;
localparam FUNCT3_BLTU  = 3'b110;
localparam FUNCT3_BGEU  = 3'b111;
localparam FUNCT3_ADDI  = 3'b000;
localparam FUNCT3_SLTI  = 3'b010;
localparam FUNCT3_SLTIU = 3'b011;
localparam FUNCT3_XORI  = 3'b100;
localparam FUNCT3_ORI   = 3'b110;
localparam FUNCT3_ANDI  = 3'b111;
localparam FUNCT3_SLLI  = 3'b001;
localparam FUNCT3_SRLI_SRAI = 3'b101;
localparam FUNCT3_ADD_SUB = 3'b000;
localparam FUNCT3_SLL   = 3'b001;
localparam FUNCT3_SLT   = 3'b010;
localparam FUNCT3_SLTU  = 3'b011;
localparam FUNCT3_XOR   = 3'b100;
localparam FUNCT3_SRL_SRA = 3'b101;
localparam FUNCT3_OR    = 3'b110;
localparam FUNCT3_AND   = 3'b111;
localparam FUNCT3_CSRRW = 3'b001;
localparam FUNCT3_CSRRS = 3'b010;
localparam FUNCT3_CSRRC = 3'b011;
localparam FUNCT3_CSRRWI = 3'b101;
localparam FUNCT3_CSRRSI = 3'b110;
localparam FUNCT3_CSRRCI = 3'b111;
localparam FUNCT3_PRIV = 3'b000;
// verilator lint_on UNUSEDPARAM
