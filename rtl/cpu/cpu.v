`default_nettype none

module cpu #(
    parameter integer INITIAL_PC = 0,
    parameter integer TRAP_PC = 0
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
    output reg we_o,
    input wire timer_interrupt,
    input wire external_interrupt
);

`include "params.vh"

localparam STATE_FETCH = 3'd0,
STATE_REG_READ = 3'd1,
STATE_EXECUTE = 3'd2,
STATE_MEMORY = 3'd3,
STATE_REG_WRITE = 3'd4,
STATE_RESET = 3'd7;

reg state_change;
reg[2:0] state;
reg[31:0] instruction;
reg[31:0] read_data;
wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];

reg pc_load;
reg pc_count;
reg[31:0] pc_value;
wire[31:0] pc;
wire[31:0] pc_inc;

reg trap_taken;
reg [31:0] mcause_;

reg [31:0] mcause;
reg [31:0] mepc;
reg [31:0] mie;
reg [31:0] mstatus;
wire [31:0] mtvec = TRAP_PC;

wire mstatus_mie = mstatus[3];

wire mie_mtie = mie[7];
wire mie_meie = mie[11];

wire timer_interrupt_enable = mstatus_mie && mie_mtie;
wire external_interrupt_enable = mstatus_mie && mie_meie;

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
wire[4:0] r_address1;
wire[31:0] r_out1;
wire[4:0] r_address2;
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
wire [11:0] csr_address = instruction[31:20];

reg[31:0] alu_op_a;
reg[31:0] alu_op_b;
wire[31:0] alu_out;
reg[31:0] alu_out_r;

wire alu_eq;
wire alu_neq;
wire alu_lt;
wire alu_ltu;
wire alu_ge;
wire alu_geu;

reg alu_eq_r;
reg alu_neq_r;
reg alu_lt_r;
reg alu_ltu_r;
reg alu_ge_r;
reg alu_geu_r;

alu alu(
   .instruction(instruction),
   .op_a(alu_op_a),
   .op_b(alu_op_b),
   .pc(pc),
   .out(alu_out),
   .eq(alu_eq),
   .neq(alu_neq),
   .lt(alu_lt),
   .ltu(alu_ltu),
   .ge(alu_ge),
   .geu(alu_geu)
);

always @(posedge(clk_i)) begin
    if(state_change) begin
        alu_out_r <= alu_out;

        alu_eq_r <= alu_eq;

        alu_neq_r <= alu_neq;

        alu_lt_r <= alu_lt;

        alu_ltu_r <= alu_ltu;

        alu_ge_r <= alu_ge;

        alu_geu_r <= alu_geu;
    end
end

always @(posedge(clk_i)) begin
    state_change <= 1;

    if(rst_i) begin
        state <= STATE_RESET;
        instruction <= 32'hxxxx_xxxx;
        mcause <= 0;
        mepc <= 0;
        mie <= 0;
        mstatus <= 0;
    end else begin
        case(state)
        STATE_FETCH:
            if(ack_i) begin
                state <= STATE_REG_READ;
                instruction <= dat_i;
            end
        STATE_REG_READ: begin
            state <= STATE_EXECUTE;

            if(opcode == OPCODE_SYSTEM) begin
                if(funct3 == FUNCT3_CSRRW) begin
                    case(csr_address)
                    CSR_MSTATUS: mstatus <= r_out1;
                    CSR_MIE: mie <= r_out1;
                    CSR_MEPC: mepc <= r_out1;
                    CSR_MCAUSE: mcause <= r_out1;
                    default: ;
                    endcase
                end
            end
        end
        STATE_EXECUTE: begin
            state <= STATE_MEMORY;
            state_change <= 0;
        end
        STATE_MEMORY:
            if(ack_i | (!mem_r_en & !mem_w_en)) begin
                state <= STATE_REG_WRITE;
                read_data <= dat_i;
            end else state_change <= 0;
        STATE_REG_WRITE: begin
            state <= STATE_FETCH;
            if(trap_taken) begin
                mcause <= mcause_;
                mepc <= pc;
            end
        end
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
    OPCODE_SYSTEM:
        case(funct3)
            FUNCT3_CSRRW,
            FUNCT3_CSRRWI,
            FUNCT3_CSRRC,
            FUNCT3_CSRRCI,
            FUNCT3_CSRRS,
            FUNCT3_CSRRSI: reg_w_en = 1;
            default: reg_w_en = 0;
        endcase
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
    pc_count = 0;
    pc_load = 0;
    pc_value = 32'hxxxx_xxxx;

    trap_taken = 0;
    mcause_ = 32'hxxxx_xxxx;

    stb_o = 0;
    cyc_o = 0;
    sel_o = 4'hx;
    dat_o = 32'hxxxx_xxxx;
    adr_o = 32'hxxxx_xxxx;
    we_o = 1'hx;

    alu_op_a = 32'hxxxx_xxxx;
    alu_op_b = 32'hxxxx_xxxx;

    w_data = 32'hxxxx_xxxx;
    w_enable = 1'b0;

    case(state)
    STATE_FETCH: begin
        stb_o = 1;
        cyc_o = 1;
        adr_o = pc;
        we_o = 0;
        sel_o = 4'b1111;
    end
    STATE_REG_READ: begin
    end
    STATE_EXECUTE: begin
        alu_op_a = r_out1;
        alu_op_b = r_out2;
    end
    STATE_MEMORY: begin
        if(mem_r_en) begin
            stb_o = 1;
            cyc_o = 1;
            adr_o = alu_out_r & ~32'h0000_0003;
            we_o = 0;
            sel_o = 4'b1111;
        end

        if(mem_w_en) begin
            stb_o = 1;
            cyc_o = 1;
            adr_o = alu_out_r & ~32'h0000_0003;
            case(funct3)
                FUNCT3_SW: dat_o = r_out2;
                FUNCT3_SH: dat_o = r_out2 << (16 * alu_out_r[1]);
                FUNCT3_SB: dat_o = r_out2 << (8 * alu_out_r[0 +: 2]);
                default: dat_o = r_out2;
            endcase
            we_o = 1;
            case(funct3)
                FUNCT3_SW: sel_o = 4'b1111;
                FUNCT3_SH: sel_o = 4'b0011 << (2 * alu_out_r[1]);
                FUNCT3_SB: sel_o = 4'b0001 << alu_out_r[0 +: 2];
                default: sel_o = 4'bxxxx;
            endcase
        end

       if((timer_interrupt && timer_interrupt_enable)
              || (external_interrupt && external_interrupt_enable)) begin
          // Prevent memory writes if interrupted. This is the only side effect
          // of the instruction, so this effectively interrupts the instruction,
          // and it can be restarted after handling the interrupt.
           stb_o = 0;
           cyc_o = 0;
           sel_o = 4'hx;
           dat_o = 32'hxxxx_xxxx;
           adr_o = 32'hxxxx_xxxx;
           we_o = 1'hx;

           trap_taken = 1;
           pc_value = TRAP_PC;
           pc_load = 1;

          if(timer_interrupt) begin
             mcause_ = {1'b1, 31'd7};
          end

          if(external_interrupt) begin
             mcause_ = {1'b1, 31'd11};
          end
       end
    end
    STATE_REG_WRITE: begin
        w_enable = reg_w_en;

        case(opcode)
            OPCODE_LOAD: begin
                case(funct3)
                    FUNCT3_LW: w_data = read_data;
                    FUNCT3_LB: w_data = $signed(read_data[8 * alu_out_r[1:0] +: 8]);
                    FUNCT3_LBU: w_data = read_data[8 * alu_out_r[1:0] +: 8];
                    FUNCT3_LH: w_data = $signed(read_data[16 * alu_out_r[1] +: 16]);
                    FUNCT3_LHU: w_data = read_data[16 * alu_out_r[1] +: 16];
                    default: w_data = 32'hxxxx_xxxx;
                endcase
            end
            OPCODE_JAL,
            OPCODE_JALR: begin
                w_data = pc_inc;
            end
            default: w_data = alu_out_r;
        endcase

        case(opcode)
            OPCODE_JAL,
            OPCODE_JALR: begin
                pc_count = 1'bx;
                pc_load = 1;
                pc_value = alu_out_r;
            end
            OPCODE_BRANCH: begin
                if((funct3 == FUNCT3_BEQ && alu_eq_r) ||
                   (funct3 == FUNCT3_BNE && alu_neq_r) ||
                   (funct3 == FUNCT3_BLT && alu_lt_r) ||
                   (funct3 == FUNCT3_BLTU && alu_ltu_r) ||
                   (funct3 == FUNCT3_BGE && alu_ge_r) ||
                   (funct3 == FUNCT3_BGEU && alu_geu_r)) begin
                    pc_count = 1'bx;
                    pc_load = 1;
                    pc_value = alu_out_r;
                end else begin
                    pc_count = 1;
                    pc_load = 0;
                    pc_value = 32'hxxxx_xxxx;
                end
            end
            default: begin
                pc_count = 1;
                pc_load = 0;
                pc_value = 32'hxxxx_xxxx;
            end
        endcase
    end
    default: ;
    endcase
end

endmodule
