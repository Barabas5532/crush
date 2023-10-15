// An assertion that will cause the simulation to exit with an exit code.
//
// This should be used over assert everywhere, so that the test can fail
// properly in CI. Iverilog will exit with a success code even when assertions
// fail during the simulation.
`define fatal_assert(condition) assert(condition) else $fatal
