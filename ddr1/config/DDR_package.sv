package DDR_pkg;
import uvm_pkg::*;

`include "uvm_macros.svh" 

`include "DDR_timingpar.sv"

`include "../sequences/DDR_seq_item.sv"
//`include "DDR_seq.sv"

`include "../sequences/ddr_wr_basic_seq_bl8_100_seq.sv"
`include "../sequences/ddr_wr_sanity_seq_bl2_100_seq.sv"

`include "../agents/DDR_sequencer.sv"
`include "../agents/DDR_driver.sv"
`include "../agents/DDR_monitor.sv"
`include "../env/DDR_scoreboard.sv"
`include "../agents/DDR_agent.sv"
`include "../env/DDR_env.sv"
`include "../tests/DDR_test.sv"
`include "../tests/ddr_wr_sanity_seq_bl2_100_test.sv"

endpackage




