module program_counter(
    input wire reset,
    input wire clk,
    input wire load,
    input wire[31:0] value,
    output wire[31:0] pc,
    output wire[31:0] pc_inc // pc + 4
);

endmodule
