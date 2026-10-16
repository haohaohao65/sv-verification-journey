package fifo_tb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "fifo_item.sv"
`include "fifo_sample.sv"
`include "fifo_smoke_sequence.sv"
`include "fifo_order_sequence.sv"
`include "fifo_boundary_sequence.sv"
`include "fifo_simultaneous_sequence.sv"
`include "fifo_wrap_sequence.sv"
`include "fifo_reset_sequence.sv"
`include "fifo_random_sequence.sv"
`include "fifo_burst_sequence.sv"
`include "fifo_sequencer.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"
`include "fifo_scoreboard.sv"
`include "fifo_coverage.sv"
`include "fifo_agent.sv"
`include "fifo_env.sv"
`include "tests/fifo_test.sv"
`include "tests/fifo_order_test.sv"
`include "tests/fifo_boundary_test.sv"
`include "tests/fifo_simultaneous_test.sv"
`include "tests/fifo_wrap_test.sv"
`include "tests/fifo_reset_test.sv"
`include "tests/fifo_random_test.sv"
`include "tests/fifo_burst_test.sv"

endpackage
