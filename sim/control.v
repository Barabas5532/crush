`default_nettype none

module control #(
    parameter integer BASE_ADDRESS
) (
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

always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hxxxxxxxx;

    // TODO address decoding, ignore everything unless adr_i is BASE_ADDRESS
    if (stb_i & cyc_i & !ack_o) begin
        ack_o <= 1;
    end

    if (stb_i & cyc_i) begin
        $finish;
    end
end

endmodule
