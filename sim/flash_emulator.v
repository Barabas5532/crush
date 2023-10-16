`default_nettype none

/* Reads a binary from the plus arg +BINARY_PATH, then exposes it over a
 * big-endian wishbone interconnect.
 */
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

        $display("Reading flash contents from %s", binary_path);

        file = $fopen(binary_path, "rb");
        length = $fread(flash, file);
        $fclose(file);

        $display("Read %0d bytes", length);
    end else begin
        $error("The BINARY_PATH plus arg must be set");
        $stop;
    end
end

always @(posedge clk_i) begin
    reg[31:0] read_data = 32'hxxxx_xxxx;
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    if (stb_i & cyc_i & !we_i & !ack_o & addressed) begin
        ack_o <= 1;

        read_data = flash[(adr_i - BASE_ADDRESS) >> 2];
        dat_o <= {{read_data[ 7: 0]},
                  {read_data[15: 8]},
                  {read_data[23:16]},
                  {read_data[31:24]}};
    end

    if (stb_i & cyc_i & we_i & addressed) begin
        $fatal(1, "Flash is not writable");
    end
end

endmodule
