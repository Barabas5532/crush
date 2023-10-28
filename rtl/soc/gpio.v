`default_nettype none

/*
 * Register map:
 * BASE_ADDRESS + 0: control register
 *
 * bit 0 to 7 of the control register can be read and written to control the
 * 8 outputs.
 *
 * bit 8 to 15 of the control register can be read to read from the 8 inputs.
 * Writes are ignored.
 *
 * This module supports only 32-bit access.
 */
module gpio #(
    parameter integer BASE_ADDRESS = 0
) (
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    // Only 32-bit access is supported
    // verilator lint_off UNUSEDSIGNAL
    input wire [3:0] sel_i,
    // verilator lint_on UNUSEDSIGNAL
    input wire [31:0] dat_i,
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o,
    input wire [7:0] pin_input,
    output reg [7:0] pin_output
);

  wire [23:0] unused = dat_i[31:8];
  reg [31:0] data;
  assign err_o = 0;
  assign rty_o = 0;

  // TODO should be (ack_o && !we_i), also check other modules
  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  always @* begin
    data = 32'hxxxx_xxxx;

    ack_o = (adr_i == BASE_ADDRESS) && stb_i && cyc_i;

    if(ack_o && !we_i) data = {{16{1'b0}}, pin_input, pin_output};
  end

  always @(posedge clk_i) begin
    if(ack_o && we_i) pin_output = dat_i[7:0];

    if(rst_i) pin_output = 0;
  end

endmodule
