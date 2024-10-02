`default_nettype none

/*
 * Interface to hard SPI unit 0.
 */
module spi #(
    parameter integer BASE_ADDRESS
) (
    input wire clk_i,
    // The memory we are trying to infer can not be reset
    // verilator lint_off UNUSEDSIGNAL
    input wire rst_i,
    // verilator lint_on UNUSEDSIGNAL
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    input wire [3:0] sel_i,
    input wire [31:0] dat_i,
    output wire [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o,
    // Flash SPI interface
    inout wire flash_clk,
    inout wire flash_miso,
    inout wire flash_mosi,
    output wire flash_cs_n,
);
  reg [31:0] data = {24'h0, spi_sbdato};

  assign ack_o = spi_sbacko;

  assign dat_o = ack_o ? data : 32'hzzzz_zzzz;

  wire addressed = (adr_i >= BASE_ADDRESS) & (adr_i < BASE_ADDRESS + 4 * 32'h10);

wire spi_sbclki = clk_i;
wire spi_sbrwi = we_i;
wire spi_sbstbi = addressed & cyc_i & stb_i;
wire [7:0] spi_sbadri = {4'b0010, adr_i[3+2:2]};
wire [7:0] spi_sbdati = dat_i[7:0];
wire spi_mi;
wire spi_si;
wire spi_scki;
wire spi_scsni = 1;
wire [7:0] spi_sbdato;
wire spi_sbacko;
wire spi_spiirq;
wire spi_spiwkup;
wire spi_so;
wire spi_soe;
wire spi_mo;
wire spi_moe;
wire spi_scko;
wire spi_sckoe;
wire [3:0] spi_mcsno;
wire [3:0] spi_mcsnoe;

SB_SPI #(.BUS_ADDR74("0b0010")) spi (
  .SBCLKI(spi_sbclki),
  .SBRWI(spi_sbrwi),
  .SBSTBI(spi_sbstbi),
  .SBADRI7(spi_sbadri[7]),
  .SBADRI6(spi_sbadri[6]),
  .SBADRI5(spi_sbadri[5]),
  .SBADRI4(spi_sbadri[4]),
  .SBADRI3(spi_sbadri[3]),
  .SBADRI2(spi_sbadri[2]),
  .SBADRI1(spi_sbadri[1]),
  .SBADRI0(spi_sbadri[0]),
  .SBDATI7(spi_sbdati[7]),
  .SBDATI6(spi_sbdati[6]),
  .SBDATI5(spi_sbdati[5]),
  .SBDATI4(spi_sbdati[4]),
  .SBDATI3(spi_sbdati[3]),
  .SBDATI2(spi_sbdati[2]),
  .SBDATI1(spi_sbdati[1]),
  .SBDATI0(spi_sbdati[0]),
  .MI(spi_mi),
  .SI(spi_si),
  .SCKI(spi_scki),
  .SCSNI(spi_scsni),
  .SBDATO7(spi_sbdato[7]),
  .SBDATO6(spi_sbdato[6]),
  .SBDATO5(spi_sbdato[5]),
  .SBDATO4(spi_sbdato[4]),
  .SBDATO3(spi_sbdato[3]),
  .SBDATO2(spi_sbdato[2]),
  .SBDATO1(spi_sbdato[1]),
  .SBDATO0(spi_sbdato[0]),
  .SBACKO(spi_sbacko),
  .SPIIRQ(spi_spiirq),
  .SPIWKUP(spi_spiwkup),
  .SO(spi_so),
  .SOE(spi_soe),
  .MO(spi_mo),
  .MOE(spi_moe),
  .SCKO(spi_scko),
  .SCKOE(spi_sckoe),
  .MCSNO3(spi_mcsno[3]),
  .MCSNO2(spi_mcsno[2]),
  .MCSNO1(spi_mcsno[1]),
  .MCSNO0(spi_mcsno[0]),
  .MCSNOE3(spi_mcsnoe[3]),
  .MCSNOE2(spi_mcsnoe[2]),
  .MCSNOE1(spi_mcsnoe[1]),
  .MCSNOE0(spi_mcsnoe[0])
);

  SB_IO #(
    .PIN_TYPE(6'b101001),
    .PULLUP(1'b1)
  ) io[2:0] (
    .PACKAGE_PIN  ({flash_mosi,    flash_miso,    flash_clk   }),
    .OUTPUT_ENABLE({spi_moe, spi_soe, spi_sckoe}),
    .D_OUT_0      ({spi_mo,  spi_so,  spi_scko }),
    .D_IN_0       ({spi_si,  spi_mi,  spi_scki })
  );

  assign flash_cs_n  = spi_mcsno[0];

endmodule
