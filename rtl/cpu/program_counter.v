`default_nettype none

module program_counter #(parameter INITIAL_PC = 0) (
    input wire reset,
    input wire clk,
    input wire count,
    input wire load,
    input wire[31:0] value,
    output reg[31:0] pc,
    output wire[31:0] pc_inc
);

assign pc_inc = pc + 4;

always @(posedge clk) begin
    if(reset) begin
        pc <= INITIAL_PC;
    end else if(load) begin
        pc <= value;
    end else if(count) begin
        pc <= pc_inc;
    end
end

endmodule
