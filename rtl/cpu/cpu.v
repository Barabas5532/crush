`default_nettype none

module cpu #(
    parameter integer INITIAL_PC
) (
    input wire clk_i,
    input wire[31:0] dat_i,
    output reg[31:0] dat_o,
    input wire rst_i,
    input wire ack_i,
    input wire err_i,
    input wire rty_i,
    output reg stb_o,
    output reg cyc_o,
    output reg[31:0] adr_o,
    output reg[3:0] sel_o,
    output reg we_o
);

`include "params.vh"

localparam STATE_FETCH = 3'd0,
STATE_REG_READ = 3'd1,
STATE_EXECUTE = 3'd2,
STATE_MEMORY = 3'd3,
STATE_REG_WRITE = 3'd4,
STATE_RESET = 3'd7;

reg[2:0] state;
reg[31:0] instruction;
wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];

reg pc_load;
reg pc_count;
reg[31:0] pc_value;
wire[31:0] pc;
wire[31:0] pc_inc;

program_counter #(.INITIAL_PC(INITIAL_PC)) program_counter(
    .reset(rst_i),
    .clk(clk_i),
    .count(pc_count),
    .load(pc_load),
    .value(pc_value),
    .pc(pc),
    .pc_inc(pc_inc)
);

reg[31:0] w_data;
reg w_enable;
wire[4:0] w_address;
reg[4:0] r_address1;
wire[31:0] r_out1;
reg[4:0] r_address2;
wire[31:0] r_out2;

registers registers(
    .clk(clk_i),
    .w_data(w_data),
    .w_enable(w_enable),
    .w_address(w_address),
    .r_address1(r_address1),
    .r_out1(r_out1),
    .r_address2(r_address2),
    .r_out2(r_out2)
);

assign r_address1 = instruction[19:15];
assign r_address2 = instruction[24:20];
assign w_address = instruction[11:7];

reg[31:0] alu_op_a;
reg[31:0] alu_op_b;
wire[31:0] alu_out;
reg[31:0] alu_out_r;
reg[31:0] alu_out_rr;

// TODO remove unused signals if possible, just need I and S type
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

alu alu(
   .instruction(instruction),
   .op_a(alu_op_a),
   .op_b(alu_op_b),
   .pc(pc),
   .out(alu_out)
);

always @(posedge(clk_i)) begin
    alu_out_r <= alu_out;
    alu_out_rr <= alu_out_r;
end

always @(posedge(clk_i)) begin
    if(rst_i) begin
        state <= STATE_RESET;
        instruction <= 32'hxxxx_xxxx;
    end else begin
        case(state)
        STATE_FETCH:
            // TODO handle error, retry correctly
            if(ack_i) begin
                state <= STATE_REG_READ;
                instruction <= dat_i;
            end
        STATE_REG_READ: state <= STATE_EXECUTE;
        // TODO maybe memory can't read in a single cycle ?
        STATE_EXECUTE: state <= STATE_MEMORY;
        STATE_MEMORY: state <= STATE_REG_WRITE;
        STATE_REG_WRITE: state <= STATE_FETCH;
        default: state <= STATE_FETCH;
        endcase
    end
end

reg reg_w_en;

always @(*) begin
    case(opcode)
    OPCODE_OP_IMM,
    OPCODE_LUI,
    OPCODE_AUIPC,
    OPCODE_OP,
    OPCODE_JAL,
    OPCODE_JALR,
    OPCODE_LOAD: reg_w_en = 1;
    default: reg_w_en = 0;
    endcase
end

reg mem_r_en;

always @(*) begin
    case(opcode)
    OPCODE_LOAD: mem_r_en = 1;
    default: mem_r_en = 0;
    endcase
end

reg mem_w_en;

always @(*) begin
    case(opcode)
    OPCODE_STORE: mem_w_en = 1;
    default: mem_w_en = 0;
    endcase
end

always @(*) begin
    stb_o <= 0;
    cyc_o <= 0;
    sel_o <= 4'hx;
    dat_o <= 32'hxxxx_xxxx;
    adr_o <= 32'hxxxx_xxxx;
    we_o <= 1'hx;

    alu_op_a <= 32'hxxxx_xxxx;
    alu_op_b <= 32'hxxxx_xxxx;

    w_data <= 32'hxxxx_xxxx;
    w_enable <= 1'b0;

    case(state)
    STATE_FETCH: begin
        stb_o <= 1;
        cyc_o <= 1;
        adr_o <= pc;
        we_o <= 0;
        sel_o <= 4'b1111;
    end
    STATE_REG_READ: begin
    end
    STATE_EXECUTE: begin
        alu_op_a <= r_out1;
        alu_op_b <= r_out2;
    end
    STATE_MEMORY: begin
        if(mem_r_en) begin
            stb_o <= 1;
            cyc_o <= 1;
            adr_o <= alu_out_r & ~32'h0000_0003;
            we_o <= 0;
            sel_o <= 4'b1111;
        end

        if(mem_w_en) begin
            stb_o <= 1;
            cyc_o <= 1;
            adr_o <= alu_out_r & ~32'h0000_0003;
            case(funct3)
                FUNCT3_SW: dat_o <= r_out2;
                FUNCT3_SH: dat_o <= r_out2 << (16 * S_immediate[1]);
                FUNCT3_SB: dat_o <= r_out2 << (8 * S_immediate[0 +: 2]);
                default: dat_o <= r_out2;
            endcase
            we_o <= 1;
            case(funct3)
                FUNCT3_SW: sel_o <= 4'b1111;
                FUNCT3_SH: sel_o <= 4'b0011 << (2 * S_immediate[1]);
                FUNCT3_SB: sel_o <= 4'b0001 << S_immediate[0 +: 2];
                default: sel_o <= 4'bxxxx;
            endcase
        end
    end
    STATE_REG_WRITE: begin
        w_enable <= reg_w_en;

        case(opcode)
            OPCODE_LOAD: begin
                case(funct3)
                    FUNCT3_LW: w_data <= dat_i;
                    FUNCT3_LB: w_data <= $signed(dat_i[8 * I_immediate[1:0] +: 8]);
                    FUNCT3_LBU: w_data <= dat_i[8 * I_immediate[1:0] +: 8];
                    FUNCT3_LH: w_data <= $signed(dat_i[16 * I_immediate[1] +: 16]);
                    FUNCT3_LHU: w_data <= dat_i[16 * I_immediate[1] +: 16];
                    default: w_data <= 32'hxxxx_xxxx;
                endcase
            end
            OPCODE_JAL,
            OPCODE_JALR: begin
                w_data <= pc_inc;
            end
            default: w_data <= alu_out_rr;
        endcase

        case(opcode)
            OPCODE_JAL,
            OPCODE_JALR: begin
                pc_count <= 1'bx;
                pc_load <= 1;
                pc_value <= alu_out_rr;
            end
            default: begin
                pc_count <= 1;
                pc_load <= 0;
                pc_value <= 32'hxxxx_xxxx;
            end
        endcase
    end
    endcase
end

endmodule
