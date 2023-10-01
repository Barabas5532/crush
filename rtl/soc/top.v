`default_nettype none

module crush (
    input wire CLK,
    input wire BTN_N,
    output wire LED0
);

wire rst_i = !BTN_N;
wire clk = CLK;

// TODO temporary so that the design is not optimised away. Create GPIO
// module.
assign LED0 = dat_i[0];

wire stb_o;
wire cyc_o;
wire[31:0] adr_o;
wire[3:0] sel_o;
wire[31:0] dat_i;
wire[31:0] dat_o;
wire we_o;
wire ack_i;
wor err_i = 0;
wor rty_i = 0;

cpu #(.INITIAL_PC('h1000_0000)) dut (
    .clk_i(clk),
    .dat_i(dat_i),
    .dat_o(dat_o),
    .rst_i(rst_i),
    .ack_i(ack_i),
    .err_i(err_i),
    .rty_i(rty_i),
    .stb_o(stb_o),
    .cyc_o(cyc_o),
    .adr_o(adr_o),
    .sel_o(sel_o),
    .we_o(we_o)
);

memory #(.BASE_ADDRESS('h1000_0000), .SIZE('h4000)) memory (
    .clk_i(clk),
    .rst_i(rst_i),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(ack_i),
    .err_o(err_i),
    .rty_o(rty_i)
);

endmodule
