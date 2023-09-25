`default_nettype none

// TODO implement signature export as required by RISCOF before finish is
// called.
//
// Connect the entire CPU memory module to this one. When the finish register
// is accessed, then save the entire memory contents to a file.

module control #(
    parameter integer BASE_ADDRESS,
    parameter integer MEMORY_SIZE
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
    output reg rty_o,
    input wire[31:0] memory[MEMORY_SIZE]
);

always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    if (stb_i & cyc_i & adr_i == BASE_ADDRESS) begin
        integer file;
        integer i;

        $display("Control register accessed, finishing simulation");

        file = $fopen("memory_dump", "w");
        for (i = 0; i < MEMORY_SIZE; i++) begin
            $fwrite(file, "%08h\n", memory[i]);
        end
        $fclose(file);

        $finish;
    end
end

endmodule
