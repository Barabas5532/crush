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
reg [31:0] instruction;

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

alu alu(
   .instruction(instruction),
   .op_a(alu_op_a),
   .op_b(alu_op_b),
   .out(alu_out)
);

always @(posedge(clk_i)) begin
    alu_out_r <= alu_out;
    alu_out_rr <= alu_out_r;
end

always @(posedge(clk_i)) begin
    if(rst_i) begin
        state <= STATE_RESET;
    end else begin
        case(state)
        STATE_FETCH:
            // TODO handle error, retry correctly
            if(ack_i) begin
                state <= STATE_REG_READ;
                instruction <= dat_i;
            end
        STATE_REG_READ: state <= STATE_EXECUTE;
        STATE_EXECUTE: state <= STATE_MEMORY;
        STATE_MEMORY: state <= STATE_REG_WRITE;
        STATE_REG_WRITE: state <= STATE_FETCH;
        default: state <= STATE_FETCH;
        endcase
    end
end

reg reg_w_en;

always @(*) begin
    case(instruction[6:0])
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

always @(*) begin
    pc_count <= 0;
    pc_load <= 0;
    pc_value <= 32'hxxxx_xxxx;

    stb_o <= 0;
    cyc_o <= 0;
    sel_o <= 4'hx;
    dat_o <= 32'hxxxx_xxxx;
    adr_o <= 32'hxxxx_xxxx;
    we_o <= 1'hx;

    alu_op_a <= 32'hxxxx_xxxx;
    alu_op_b <= 32'hxxxx_xxxx;

    w_data <= 32'hxxxx_xxxx;
    w_enable <= 1'bx;

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
    end
    STATE_REG_WRITE: begin
        w_data <= alu_out_rr;
        w_enable <= reg_w_en;
        pc_count <= 1;
    end
    endcase
end

endmodule
