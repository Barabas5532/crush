`default_nettype none

module top (
    input wire CLK,
    input wire BTN_N,
    input wire BTN1,
    output wire LED1,
    output wire LED2
);

wire rst_i = !BTN_N;
wire clk = CLK;

wire stb_o;
wire cyc_o;
wire[31:0] adr_o;
wire[3:0] sel_o;
wire[31:0] dat_i;
wire[31:0] dat_o;
wire we_o;
wire ack_i;
wire err_i;
wire rty_i;

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

wire memory_ack_o;
wire memory_rty_o;
wire memory_err_o;
  memory_infer #(
      .BASE_ADDRESS('h1000_0000),
      .SIZE('h800)
  ) memory (
      .clk_i(clk),
      .rst_i(rst_i),
      .stb_i(stb_o),
      .cyc_i(cyc_o),
      .adr_i(adr_o),
      .sel_i(sel_o),
      .dat_i(dat_o),
      .dat_o(dat_i),
      .we_i (we_o),
      .ack_o(memory_ack_o),
      .err_o(memory_err_o),
      .rty_o(memory_rty_o)
  );

  initial $readmemh("fw.data", memory.mem);

wire gpio_ack_o;
wire gpio_rty_o;
wire gpio_err_o;
wire [5:0] unused;
gpio #(.BASE_ADDRESS('h4000_0000)) gpio (
    .clk_i(clk),
    .rst_i(rst_i),
    .stb_i(stb_o),
    .cyc_i(cyc_o),
    .adr_i(adr_o),
    .sel_i(sel_o),
    .dat_i(dat_o),
    .dat_o(dat_i),
    .we_i(we_o),
    .ack_o(gpio_ack_o),
    .err_o(gpio_err_o),
    .rty_o(gpio_rty_o),
    .pin_input({{7{1'b0}}, BTN1}),
    .pin_output({unused, LED2, LED1})
);

assign ack_i = memory_ack_o | gpio_ack_o;
assign err_i = memory_err_o | gpio_err_o;
assign rty_i = memory_rty_o | gpio_rty_o;

endmodule
