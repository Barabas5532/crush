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

## Demo SoCs

### Basic Configuration (module top)

#### Boot process

All firmware executes directly from configurable block RAM. There is no support
for booting from flash. The block RAM stores both the executable code and the
system RAM.

#### Vectors

| Vector | Address     |
|--------|-------------|
| Reset  | 0x1000_0000 |


#### Memory Map

| Address     | Size (bytes) | Description |
|-------------|--------------|-------------|
| 0x1000_0000 | 8192         | Block RAM   |
| 0x4000_0000 |              | GPIO        |

### RTOS configuration (module top_freertos)

#### Boot process

The first stage bootloader stored in block RAM copies program data from flash to
RAM, then jumps to the "Boot entry" vector at the top of RAM (0x1000_0000).
After the bootloader completes, the application runs from SPRAM and the flash is
not used any more.

#### Vectors

| Vector               | Address     |
|----------------------|-------------|
| Reset                | 0x0000_0000 |
| Bootloader app entry | 0x1000_0000 |
| Interrupt            | 0x1000_0100 |

#### Memory Map

| Address     | Size (bytes) | Description    |
|-------------|--------------|----------------|
| 0x0000_0000 | 1024         | Boot block RAM |
| 0x1000_0000 | 65536        | SPRAM          |
| 0x4000_0000 |              | GPIO           |
| 0x5000_0000 |              | SPI            |

## References

The SPI flash bootloader is based on the following open source libraries:

https://github.com/no2fpga/no2bootloader

https://github.com/chipsalliance/VeeRwolf

https://github.com/olofk/simple_spi
