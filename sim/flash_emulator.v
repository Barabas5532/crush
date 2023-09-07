`default_nettype none

module flash_emulator #(
    parameter integer BASE_ADDRESS,
    parameter integer SIZE
) (
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    input wire[31:0] adr_i,
    input wire[3:0] sel_i,
    input wire[31:0] dat_i,
    output reg[31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);

reg[31:0] flash[SIZE];

initial begin
    string binary_path;
    if($value$plusargs("BINARY_PATH=%s", binary_path)) begin
        $readmemh(binary_path, flash);
    end else begin
        $error("The BINARY_PATH plus arg must be set");
        $stop;
    end
end

always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    // TODO address decoding, ignore everything unless adr_i is in range of
    // [BASE_ADDRESS, BASE_ADDRESS + SIZE - 1]
    if (stb_i & cyc_i & !ack_o) begin
        ack_o <= 1;
    end

    if (stb_i & cyc_i & !we_i) begin
        dat_o <= flash[adr_i];
    end
end

endmodule
