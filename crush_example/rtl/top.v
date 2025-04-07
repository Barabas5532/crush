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

wire        wb_inst_stb_o;
wire        wb_inst_cyc_o;
wire[31:0]  wb_inst_adr_o;
wire[3:0]   wb_inst_sel_o;
wire[31:0]  wb_inst_dat_i;
wire[31:0]  wb_inst_dat_o;
wire        wb_inst_we_o;
wire        wb_inst_ack_i;
wire        wb_inst_err_i;
wire        wb_inst_rty_i;

wire        wb_data_stb_o;
wire        wb_data_cyc_o;
wire[31:0]  wb_data_adr_o;
wire[3:0]   wb_data_sel_o;
wire[31:0]  wb_data_dat_i;
wire[31:0]  wb_data_dat_o;
wire        wb_data_we_o;
wire        wb_data_ack_i;
wire        wb_data_err_i;
wire        wb_data_rty_i;

crush_cpu #(.INITIAL_PC('h0000_0000)) cpu (
    .clk_i(clk),
    .rst_i(rst_i),
    .wb_inst_dat_i(wb_inst_dat_i),
    .wb_inst_dat_o(wb_inst_dat_o),
    .wb_inst_ack_i(wb_inst_ack_i),
    .wb_inst_err_i(wb_inst_err_i),
    .wb_inst_rty_i(wb_inst_rty_i),
    .wb_inst_stb_o(wb_inst_stb_o),
    .wb_inst_cyc_o(wb_inst_cyc_o),
    .wb_inst_adr_o(wb_inst_adr_o),
    .wb_inst_sel_o(wb_inst_sel_o),
    .wb_inst_we_o(wb_inst_we_o),
    .wb_data_dat_i(wb_data_dat_i),
    .wb_data_dat_o(wb_data_dat_o),
    .wb_data_ack_i(wb_data_ack_i),
    .wb_data_err_i(wb_data_err_i),
    .wb_data_rty_i(wb_data_rty_i),
    .wb_data_stb_o(wb_data_stb_o),
    .wb_data_cyc_o(wb_data_cyc_o),
    .wb_data_adr_o(wb_data_adr_o),
    .wb_data_sel_o(wb_data_sel_o),
    .wb_data_we_o(wb_data_we_o)
);

wire wb_inst_instruction_memory_ack_o;
wire wb_inst_instruction_memory_rty_o;
wire wb_inst_instruction_memory_err_o;
  memory_infer #(
      .BASE_ADDRESS('h0000_0000),
      .SIZE('h400),
      .READMEMH_FILE("inst.data")
  ) instruction_memory (
      .clk_i(clk),
      .rst_i(rst_i),
      .stb_i(wb_inst_stb_o),
      .cyc_i(wb_inst_cyc_o),
      .adr_i(wb_inst_adr_o),
      .sel_i(wb_inst_sel_o),
      .dat_i(wb_inst_dat_o),
      .dat_o(wb_inst_dat_i),
      .we_i (wb_inst_we_o),
      .ack_o(wb_inst_instruction_memory_ack_o),
      .err_o(wb_inst_instruction_memory_err_o),
      .rty_o(wb_inst_instruction_memory_rty_o)
  );

wire wb_data_memory_ack_o;
wire wb_data_memory_rty_o;
wire wb_data_memory_err_o;
  memory_infer #(
      .BASE_ADDRESS('h1000_0000),
      .SIZE('h400),
      .READMEMH_FILE("data.data")
  ) memory (
      .clk_i(clk),
      .rst_i(rst_i),
      .stb_i(wb_data_stb_o),
      .cyc_i(wb_data_cyc_o),
      .adr_i(wb_data_adr_o),
      .sel_i(wb_data_sel_o),
      .dat_i(wb_data_dat_o),
      .dat_o(wb_data_dat_i),
      .we_i (wb_data_we_o),
      .ack_o(wb_data_memory_ack_o),
      .err_o(wb_data_memory_err_o),
      .rty_o(wb_data_memory_rty_o)
  );

wire wb_data_gpio_ack_o;
wire wb_data_gpio_rty_o;
wire wb_data_gpio_err_o;
wire [5:0] unused;
gpio #(.BASE_ADDRESS('h4000_0000)) gpio (
    .clk_i(clk),
    .rst_i(rst_i),
    .stb_i(wb_data_stb_o),
    .cyc_i(wb_data_cyc_o),
    .adr_i(wb_data_adr_o),
    .sel_i(wb_data_sel_o),
    .dat_i(wb_data_dat_o),
    .dat_o(wb_data_dat_i),
    .we_i(wb_data_we_o),
    .ack_o(wb_data_gpio_ack_o),
    .err_o(wb_data_gpio_err_o),
    .rty_o(wb_data_gpio_rty_o),
    .pin_input({{7{1'b0}}, BTN1}),
    .pin_output({unused, LED2, LED1})
);

assign wb_data_ack_i = wb_data_memory_ack_o | wb_data_gpio_ack_o;
assign wb_data_err_i = wb_data_memory_err_o | wb_data_gpio_err_o;
assign wb_data_rty_i = wb_data_memory_rty_o | wb_data_gpio_rty_o;

assign wb_inst_ack_i = wb_inst_instruction_memory_ack_o;
assign wb_inst_err_i = wb_inst_instruction_memory_err_o;
assign wb_inst_rty_i = wb_inst_instruction_memory_rty_o;

endmodule
