`default_nettype none

module memory(
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    output reg stall_o,
    input wire[31:0] adr_i,
    input wire[3:0] sel_i,
    input wire[31:0] dat_i,
    output reg[31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);

// TODO use primitive for ICE40 SPRAM, or test that this is inferred
// correctly
reg[31:0] memory[16383:0];

always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hxxxxxxxx;

    // TODO need address decoding here, we should only respond to some
    // addresses, not all addresses. How to implement?
    // - Directly decode the address in each slave, and ignore write/read
    // unless the correct address is being used
    // - Have the individual components ignore the address space, and have
    // a top level address decoder gating their enables
    // - Check WB spec for recommended setup
    if (stb_i & cyc_i & !ack_o) begin
        ack_o <= 1;
    end

    if (stb_i & cyc_i & ack_o & we_i) begin
        memory[adr_i] <= dat_i;
    end

    if (stb_i & cyc_i & !we_i) begin
        dat_o <= memory[adr_i];
    end
end

endmodule
