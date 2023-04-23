`default_nettype none

module registers(
    input wire clk,
    input wire[31:0] w_data,
    input wire w_enable,
    input wire[4:0] w_address,
    output reg[4:0] r_address1,
    output reg[31:0] r_out1,
    output reg[4:0] r_address2,
    output reg[31:0] r_out2
);

reg memory[31:0][31:0];

always @(posedge clk) begin
    r_out1 = memory[r_address1];
    r_out2 = memory[r_address2];

    if(w_enable) memory[w_address] = w_data;
end

endmodule
