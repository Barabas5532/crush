`default_nettype none

module inst_immediate_decode_tb;

reg[31:0] inst;
wire[31:0] I_immediate;
wire[31:0] S_immediate;
wire[31:0] B_immediate;
wire[31:0] U_immediate;
wire[31:0] J_immediate;

inst_immediate_decode dut (
    .inst(inst),
    .I_immediate(I_immediate),
    .S_immediate(S_immediate),
    .B_immediate(B_immediate),
    .U_immediate(U_immediate),
    .J_immediate(J_immediate)
);

initial begin
    $dumpfile("inst_immediate_decode.vcd");
    $dumpvars;

    #1
    // I format
    inst = 32'h80_00_00_00;
    #1
    assert(&I_immediate[31:11] == 1'b1);

    #1
    inst = ~32'h80_00_00_00;
    #1
    assert(|I_immediate[31:11] == 1'b0);

    #1
    inst = 32'b01000110_00000000_00000000_00000000;
    #1
    assert(I_immediate[10:5] == 6'b100011);

    #1
    inst = ~32'b01000110_00000000_00000000_00000000;
    #1
    assert(I_immediate[10:5] == ~6'b100011);

    #1
    inst = 32'b00000001_01100000_00000000_00000000;
    #1
    assert(I_immediate[4:1] == 4'b1011);

    #1
    inst = ~32'b00000001_01100000_00000000_00000000;
    #1
    assert(I_immediate[4:1] == ~4'b1011);

    #1
    inst = 32'b00000000_00010000_00000000_00000000;
    #1
    assert(I_immediate[0] == 1'b1);

    #1
    inst = ~32'b00000000_00010000_00000000_00000000;
    #1
    assert(I_immediate[0] == ~1'b1);

    // S format
    #1
    inst = 32'h80_00_00_00;
    #1
    assert(&S_immediate[31:11] == 1'b1);

    #1
    inst = ~32'h80_00_00_00;
    #1
    assert(|S_immediate[31:11] == 1'b0);

    #1
    inst = 32'b01000110_00000000_00000000_00000000;
    #1
    assert(S_immediate[10:5] == 6'b100011);

    #1
    inst = ~32'b01000110_00000000_00000000_00000000;
    #1
    assert(S_immediate[10:5] == ~6'b100011);

    #1
    inst = 32'b00000000_00000000_00001011_00000000;
    #1
    assert(S_immediate[4:1] == 4'b1011);

    #1
    inst = ~32'b00000000_00000000_00001011_00000000;
    #1
    assert(S_immediate[4:1] == ~4'b1011);

    #1
    inst = 32'b00000000_00000000_00000000_10000000;
    #1
    assert(S_immediate[0] == 1'b1);

    #1
    inst = ~32'b00000000_00000000_00000000_10000000;
    #1
    assert(S_immediate[0] == ~1'b1);

    // B format
    #1
    inst = 32'h80_00_00_00;
    #1
    assert(&B_immediate[31:12] == 1'b1);

    #1
    inst = ~32'h80_00_00_00;
    #1
    assert(|B_immediate[31:12] == 1'b0);

    #1
    inst = 32'b00000000_00000000_00000000_10000000;
    #1
    assert(B_immediate[11] == 1'b1);

    #1
    inst = ~32'b00000000_00000000_00000000_10000000;
    #1
    assert(B_immediate[11] == ~1'b1);

    #1
    inst = 32'b01000110_00000000_00000000_00000000;
    #1
    assert(B_immediate[10:5] == 6'b100011);

    #1
    inst = ~32'b01000110_00000000_00000000_00000000;
    #1
    assert(B_immediate[10:5] == ~6'b100011);

    #1
    inst = 32'b00000000_00000000_00001011_00000000;
    #1
    assert(B_immediate[4:1] == 4'b1011);

    #1
    inst = ~32'b00000000_00000000_00001011_00000000;
    #1
    assert(B_immediate[4:1] == ~4'b1011);

    #1
    inst = ~32'b00000000_00000000_00000000_00000000;
    #1
    assert(B_immediate[0] == 1'b0);
end

endmodule
