`default_nettype none

module inst_decode_register(
    input wire[31:0] inst,
    output reg[4:0] rs1,
    output reg[4:0] rs2,
    output reg[4:0] rd
);

always @* begin
    rs2 = inst[24:20];
    rs1 = inst[19:15];
    rd = inst[11:7];
end

endmodule
