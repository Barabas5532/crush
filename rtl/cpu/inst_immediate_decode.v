`default_nettype none

module inst_immediate_decode(
    input wire[31:0] inst,
    output reg[31:0] I_immediate,
    output reg[31:0] S_immediate,
    output reg[31:0] B_immediate,
    output reg[31:0] U_immediate,
    output reg[31:0] J_immediate
);


always @* begin
    I_immediate = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
    S_immediate = { {21{inst[31]}}, inst[30:25], inst[11:8],  inst[7]};
    B_immediate = { {20{inst[31]}}, inst[7],     inst[30:25], inst[11:8], 1'b0};
    U_immediate = { inst[31],       inst[30:20], inst[19:12], 12'b0};
    J_immediate = { {12{inst[31]}}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0};
end

endmodule
