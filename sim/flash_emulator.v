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
    output wire[31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o
);

reg[31:0] mem[SIZE];

  wire[31:0] mask = {{8{sel_i[3]}}, {8{sel_i[2]}}, {8{sel_i[1]}}, {8{sel_i[0]}}};
  wire[31:0] memory_address = (adr_i - BASE_ADDRESS) >> 2;
  wire[31:0] value = mem[memory_address];

wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < (BASE_ADDRESS + SIZE));

initial begin
    string binary_path;
    if($value$plusargs("BINARY_PATH=%s", binary_path)) begin
        integer file;
        integer length;

        $display("Reading flash contents from %s", binary_path);

        file = $fopen(binary_path, "rb");
        length = $fread(mem, file);
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

    if (stb_i & cyc_i & !ack_o & addressed) begin
      ack_o <= 1;
    end

    if (stb_i & cyc_i & addressed & we_i) begin
     mem[memory_address] <= (value & ~mask) | (dat_i & mask);
    end

    if (stb_i & cyc_i & addressed & !we_i) begin
      dat_o <= mem[memory_address];
    end
end

endmodule
