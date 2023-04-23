// vim:syntax=verilog:

// Based on RV32I Base Instruction Set table from
// The RISC-V Instruction Set Manual
// Volume I: Unprivileged ISA
// Document Version 20191213
// Chapter 24

localparam OPCODE_OP_IMM   7'b0010011
localparam OPCODE_LUI      7'b0110111
localparam OPCODE_AUIPC    7'b0010111
localparam OPCODE_OP       7'b0010011
localparam OPCODE_JAL      7'b1101111
localparam OPCODE_JALR     7'b1100111
localparam OPCODE_BRANCH   7'b1100011
localparam OPCODE_LOAD     7'b0000011
localparam OPCODE_STORE    7'b0100011
localparam OPCODE_MISC_MEM 7'b0100011
localparam OPCODE_SYSTEM   7'b1110011
