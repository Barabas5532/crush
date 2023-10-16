`default_nettype none

/*
 * Register map:
 * BASE_ADDRESS + 0: start of signature region
 * BASE_ADDRESS + 4: end of signature region
 * BASE_ADDRESS + 8: on read or write, the signature will be dumped and the
 *                   simulation will end
 *
 * This module implements RISCOF signature output and simulation halt. To
 * output the signature, write the value of the rvtest_sig_begin label and the
 * address of rvtest_sig_end to the corresponding register. Then read or
 * write the final register to end the simulation.
 *
 * Before the simulation ends, the data in memory at
 * (start_address - MEMORY_BASE_ADDRESS)/4 up to (end_address
 * - MEMORY_BASE_ADDRESS)/4 exclusive will be output to the file system at the
 * path given by the SIGNATURE_PATH plus arg.
 *
 * Parameters:
 *
 * - BASE_ADDRESS: The base address of the control registers for this module.
 * - MEMORY_BASE_ADDRESS: The base address of the memory module of the system.
 * - MEMORY_SIZE: The size of the memory module in words
 */
module control #(
    parameter integer BASE_ADDRESS,
    parameter integer MEMORY_BASE_ADDRESS,
    parameter integer MEMORY_SIZE
) (
    input wire clk_i,
    input wire rst_i,
    input wire stb_i,
    input wire cyc_i,
    input wire [31:0] adr_i,
    input wire [3:0] sel_i,
    input wire [31:0] dat_i,
    output reg [31:0] dat_o,
    input wire we_i,
    output reg ack_o,
    output reg err_o,
    output reg rty_o,
    input wire [31:0] memory[MEMORY_SIZE]
);

  reg [31:0] start_address;
  reg [31:0] end_address;

  always @(posedge clk_i) begin
    ack_o <= 0;
    err_o <= 0;
    rty_o <= 0;
    dat_o <= 32'hzzzz_zzzz;

    if (stb_i & cyc_i & !ack_o) begin
      ack_o <= 1;
      case (adr_i)
        BASE_ADDRESS: begin
          start_address <= dat_i;
        end
        BASE_ADDRESS + 4: begin
          end_address <= dat_i;
        end
        BASE_ADDRESS + 8: begin
          string signature_path;

          $display("Control register accessed, finishing simulation");
          $display("Dumping memory from %08h to %08h", start_address, end_address);

          if ($value$plusargs("SIGNATURE_PATH=%s", signature_path)) begin
            integer file;
            integer i;

            $display("Writing test signature to %s", signature_path);

            file = $fopen(signature_path, "w");
            for (i = start_address; i < end_address; i += 4) begin
              $fwrite(file, "%08h\n", memory[(i - MEMORY_BASE_ADDRESS) >> 2]);
            end
            $fclose(file);
          end else begin
            $error("The SIGNATURE_PATH plus arg must be set");
            $stop;
          end

          $finish;
        end
      endcase
    end
  end

endmodule
