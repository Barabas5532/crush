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
wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < (BASE_ADDRESS + SIZE));

initial begin
    string binary_path;
    if($value$plusargs("BINARY_PATH=%s", binary_path)) begin
        integer file;
        integer length;
        integer i;

        $display("Reading flash contents from %s", binary_path);

        file = $fopen(binary_path, "rb");
        length = $fread(flash, file);
        $display("Read %0d bytes", length);
        $fclose(file);

        for (i = 0; i < length / 4; i = i + 1) begin
            $display("flash[%0d] = 0x%08h", i, flash[i]);
        end
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
    if (stb_i & cyc_i & !ack_o & addressed) begin
        ack_o <= 1;
    end

    if (stb_i & cyc_i & !we_i & addressed) begin
        dat_o <= flash[(adr_i - BASE_ADDRESS) >> 2];
    end
end

endmodule
