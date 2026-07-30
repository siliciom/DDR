package DDR_pkg;
import uvm_pkg::*;

`include "uvm_macros.svh"
`include "DDR_defines.sv"


`include "DDR_timingpar.sv"

`include "../sequences/DDR_seq_item.sv"
////////////////////////////jyothi////////////////////////
`include "../sequences/ddr_wr_basic_intlv_bl8_100_seq.sv"
`include "../sequences/ddr_wr_sanity_seq_bl2_100_seq.sv"
`include "../sequences/ddr_wr_ap_seq_bl4_100_seq.sv"
`include "../sequences/ddr_w_ap_intlv_bl4_100_seq.sv"
`include "../sequences/ddr_mul_wr_intlv_bl4_100_X16_seq.sv"
`include "../sequences/ddr_mul_wr_intlv_bl4_100_X8_seq.sv"
`include "../sequences/ddr_mul_wr_intlv_bl4_100_X4_seq.sv"
`include "../sequences/ddr_wr_bst_seq_bl4_100_seq.sv"
`include "../sequences/ddr_act4_wr_pre_data_seq.sv"
`include "../sequences/ddr_rd_without_wr_bl2_100_seq.sv"
/////////////////////pariksith//////////////////////////
`include "../sequences/ddr_wr_sanity_intlv_bl2_100_seq.sv"
`include "../sequences/ddr_wr_ap_intlv_bl4_100_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl8_100_X16_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl8_100_X8_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl8_100_X4_seq.sv"
`include "../sequences/ddr_time_par_seq.sv"
`include "../sequences/ddr_write_dm_seq_bl4_100_seq.sv"
`include "../sequences/ddr_wr_bst_intlv_bl4_100_seq.sv"
`include "../sequences/ddr_wr_auto_pre_bfr_data_cmp_seq.sv"

/////////////////////////saketh///////////////////
`include "../sequences/ddr_wr_basic_intlv_bl4_100_seq.sv"
`include "../sequences/ddr_w_ap_seq_bl8_100_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl4_100_X8_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl4_100_X4_seq.sv"
`include "../sequences/ddr_wr_bst_intlv_bl8_100_seq.sv"
`include "../sequences/ddr_all_cmd_fsm_seq.sv"
`include "../sequences/ddr_act_2_time_no_pre_btwn_seq.sv"
`include "../sequences/ddr_write_dm_seq_bl8_100_seq.sv"

////////////////////anitha//////////////////
`include "../sequences/ddr_mul_wr_intlv_bl8_100_X16_seq.sv"
`include "../sequences/ddr_mul_wr_intlv_bl8_100_X8_seq.sv"
`include "../sequences/ddr_mul_wr_intlv_bl8_100_X4_seq.sv"
`include "../sequences/ddr_wr_basic_seq_bl4_100_seq.sv"
`include "../sequences/ddr_w_ap_intlv_bl8_100_seq.sv"
`include "../sequences/ddr_write_dm_intlv_bl4_100_seq.sv"
`include "../sequences/ddr_wr_bst_seq_bl8_100_seq.sv"
`include "../sequences/ddr_wr_without_act_err_seq.sv"
`include "../sequences/ddr_wr_pd_seq_bl4_100_seq.sv"
`include "../sequences/ddr_act4_wr_op_data_seq.sv"


/////////////HARSH//////////////////
`include "../sequences/ddr_wr_basic_seq_bl8_100_seq.sv"
`include "../sequences/ddr_wr_ovr_wr_data_seq.sv"
`include "../sequences/ddr_mul_wr_seq_bl4_100_X16_seq.sv"
`include "../sequences/ddr_wr_ap_seq_bl8_100_seq.sv"
`include "../sequences/ddr_wr_ap_intlv_bl8_100_seq.sv"
`include "../sequences/ddr_w_ap_seq_bl4_100_seq.sv"
`include "../sequences/ddr_write_dm_intlv_bl8_100_seq.sv"
`include "../sequences/ddr_wr_without_pre_seq.sv"


`include "../agents/DDR_sequencer.sv"
`include "../agents/DDR_driver.sv"
`include "../agents/DDR_monitor.sv"
`include "../agents/DDR_agent.sv"
`include "../env/DDR_scoreboard.sv"
`include "../env/ddr_subscriber.sv"
`include "../env/DDR_env.sv"
`include "../tests/DDR_test.sv"
///////////////////////////////Jyothi/////////////////////
`include "../tests/ddr_wr_basic_intlv_bl8_100_test.sv"
`include "../tests/ddr_wr_sanity_seq_bl2_100_test.sv"
`include "../tests/ddr_wr_ap_seq_bl4_100_test.sv"
`include "../tests/ddr_w_ap_intlv_bl4_100_test.sv"
`include "../tests/ddr_mul_wr_intlv_bl4_100_X16_test.sv"
`include "../tests/ddr_mul_wr_intlv_bl4_100_X8_test.sv"
`include "../tests/ddr_mul_wr_intlv_bl4_100_X4_test.sv"
`include "../tests/ddr_wr_bst_seq_bl4_100_test.sv"
`include "../tests/ddr_act4_wr_pre_data_test.sv"
`include "../tests/ddr_rd_without_wr_bl2_100_test.sv"

//////////////////////parikshith///////////////////////
`include "../tests/ddr_wr_sanity_intlv_bl2_100_test.sv"
`include "../tests/ddr_wr_ap_intlv_bl4_100_test.sv"
`include "../tests/ddr_mul_wr_seq_bl8_100_X16_test.sv"
`include "../tests/ddr_mul_wr_seq_bl8_100_X8_test.sv"
`include "../tests/ddr_mul_wr_seq_bl8_100_X4_test.sv"
`include "../tests/ddr_time_par_test.sv"
`include "../tests/ddr_write_dm_seq_bl4_100_test.sv"
`include "../tests/ddr_wr_bst_intlv_bl4_100_test.sv"
`include "../tests/ddr_wr_auto_pre_bfr_data_cmp_test.sv"
//////////////////saketh////////////////////////
`include "../tests/ddr_wr_basic_intlv_bl4_100_test.sv"
`include "../tests/ddr_w_ap_seq_bl8_100_test.sv"
`include "../tests/ddr_mul_wr_seq_bl4_100_X8_test.sv"
`include "../tests/ddr_mul_wr_seq_bl4_100_X4_test.sv"
`include "../tests/ddr_wr_bst_intlv_bl8_100_test.sv"
`include "../tests/ddr_all_cmd_fsm_test.sv"
`include "../tests/ddr_act_2_time_no_pre_btwn_test.sv"
`include "../tests/ddr_write_dm_seq_bl8_100_test.sv"

////////////////anitha/////////////////////
`include "../tests/ddr_mul_wr_intlv_bl8_100_X16_test.sv"
`include "../tests/ddr_mul_wr_intlv_bl8_100_X8_test.sv"
`include "../tests/ddr_mul_wr_intlv_bl8_100_X4_test.sv"
`include "../tests/ddr_wr_basic_seq_bl4_100_test.sv"
`include "../tests/ddr_w_ap_intlv_bl8_100_test.sv"
`include "../tests/ddr_write_dm_intlv_bl4_100_test.sv"
`include "../tests/ddr_wr_bst_seq_bl8_100_test.sv"
`include "../tests/ddr_wr_without_act_err_test.sv"
`include "../tests/ddr_act4_wr_op_data_test.sv"
`include "../tests/ddr_wr_pd_seq_bl4_100_test.sv"


////////////////HARSH//////////////////
`include "../tests/ddr_wr_basic_seq_bl8_100_test.sv"
`include "../tests/ddr_wr_ovr_wr_data_test.sv"
`include "../tests/ddr_mul_wr_seq_bl4_100_X16_test.sv"
`include "../tests/ddr_wr_ap_seq_bl8_100_test.sv"
`include "../tests/ddr_wr_ap_intlv_bl8_100_test.sv"
`include "../tests/ddr_w_ap_seq_bl4_100_test.sv"
`include "../tests/ddr_write_dm_intlv_bl8_100_test.sv"
`include "../tests/ddr_wr_without_pre_test.sv"

endpackage




