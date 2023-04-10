= Crush RISC-V Processor =

== Tech stack ==

| Technology | Notes |
| ===        | ===   |
| Verilog (IEEE 1364-2005) | Picked over VHDL because there is better open source tooling available. |
| [svlint](https://github.com/dalance/svlint) + [svls](https://github.com/dalance/svls) | Standard LSP linter that can integrate with most text editors. |
| Verilator | Simulator. This is capable of using C++ testbenches, but the project uses only behavioural Verilog testbeches. |
