# Crush RISC-V Processor

Goals:

- Create a functional RISC-V processor that can execute programs compiled with
  off the shelf builds of GCC
- The design should fit onto an Lattice iCE40 FPGA (
  [TinyFPGA BX](https://tinyfpga.com/)
  or
  [iCEBreaker](https://1bitsquared.com/products/icebreaker)) with some space
  left over for peripherals or other designs outside of the system-on-a-chip
- Design should be compatible with the
  [yosys open source tools for iCE40](https://github.com/YosysHQ/icestorm)
- Support third-party memory mapped peripherals using a standard interconnect
  (Wishbone, ARM AMBA, AXI, etc)
- Passes the [RISC-V Architectural Test Framework (RISCOF)](https://github.com/riscv-software-src/riscof) tests


## Tech stack

| Technology | Notes |
| ---        | ---   |
| Verilog (IEEE 1364-2005) | Picked over VHDL because there is better open source tooling available. |
| [verible](https://github.com/chipsalliance/verible) | Standard LSP linter that can integrate with most text editors. |
| [FuseSoC](https://github.com/olofk/fusesoc) | Build tool that simplifies running the testbenches and synthesis tools. |
| [RISCOF, a RISC-V Architectural Test Framework](https://github.com/riscv-software-src/riscof) | The design passes all tests provided by RISCOF. See the `tools/compliance` folder. |
