`default_nettype none

module registers(
    input wire clk,
    input wire[31:0] w_data,
    input wire w_enable,
    input wire[4:0] w_address,
    input wire[4:0] r_address1,
    output reg[31:0] r_out1,
    input wire[4:0] r_address2,
    output reg[31:0] r_out2
);

reg[31:0] memory[32];

// These wires are here only so that icarus will include them in the VCD.
// Arrays are not included by default.
wire[31:0] x0 = memory[0];
wire[31:0] x1 = memory[1];
wire[31:0] x2 = memory[2];
wire[31:0] x3 = memory[3];
wire[31:0] x4 = memory[4];
wire[31:0] x5 = memory[5];
wire[31:0] x6 = memory[6];
wire[31:0] x7 = memory[7];
wire[31:0] x8 = memory[8];
wire[31:0] x9 = memory[9];
wire[31:0] x10 = memory[10];
wire[31:0] x11 = memory[11];
wire[31:0] x12 = memory[12];
wire[31:0] x13 = memory[13];
wire[31:0] x14 = memory[14];
wire[31:0] x15 = memory[15];
wire[31:0] x16 = memory[16];
wire[31:0] x17 = memory[17];
wire[31:0] x18 = memory[18];
wire[31:0] x19 = memory[19];
wire[31:0] x20 = memory[20];
wire[31:0] x21 = memory[21];
wire[31:0] x22 = memory[22];
wire[31:0] x23 = memory[23];
wire[31:0] x24 = memory[24];
wire[31:0] x25 = memory[25];
wire[31:0] x26 = memory[26];
wire[31:0] x27 = memory[27];
wire[31:0] x28 = memory[28];
wire[31:0] x29 = memory[29];
wire[31:0] x30 = memory[30];
wire[31:0] x31 = memory[31];

  task reset_memory();
    integer i;
    for (i = 0; i < 32; i++) begin
      memory[i] = 0;
    end
  endtask

  initial begin
      reset_memory();
  end

always @(posedge clk) begin
    r_out1 = memory[r_address1];
    r_out2 = memory[r_address2];

    if(w_enable & w_address > 0) memory[w_address] = w_data;
end

endmodule
