package DDR_pkg;
import uvm_pkg::*;

`include "uvm_macros.svh"
`include "DDR_defines.sv"


`include "DDR_timingpar.sv"

`include "DDR_seq_item.sv"
////////////////////////////jyothi////////////////////////
`include "ddr_wr_basic_intlv_bl8_100_seq.sv"
`include "ddr_wr_sanity_seq_bl2_100_seq.sv"
`include "ddr_wr_ap_seq_bl4_100_seq.sv"
`include "ddr_w_ap_intlv_bl4_100_seq.sv"
`include "ddr_mul_wr_intlv_bl4_100_X16_seq.sv"
`include "ddr_mul_wr_intlv_bl4_100_X8_seq.sv"
`include "ddr_mul_wr_intlv_bl4_100_X4_seq.sv"
`include "ddr_wr_bst_seq_bl4_100_seq.sv"
`include "ddr_act4_wr_pre_data_seq.sv"
`include "ddr_rd_without_wr_bl2_100_seq.sv"
/////////////////////pariksith//////////////////////////
`include "ddr_wr_sanity_intlv_bl2_100_seq.sv"
`include "ddr_wr_ap_intlv_bl4_100_seq.sv"
`include "ddr_mul_wr_seq_bl8_100_X16_seq.sv"
`include "ddr_mul_wr_seq_bl8_100_X8_seq.sv"
`include "ddr_mul_wr_seq_bl8_100_X4_seq.sv"
`include "ddr_time_par_seq.sv"
`include "ddr_write_dm_seq_bl4_100_seq.sv"
`include "ddr_wr_bst_intlv_bl4_100_seq.sv"
`include "ddr_wr_auto_pre_bfr_data_cmp_seq.sv"

/////////////////////////saketh///////////////////
`include "ddr_wr_basic_intlv_bl4_100_seq.sv"
`include "ddr_w_ap_seq_bl8_100_seq.sv"
`include "ddr_mul_wr_seq_bl4_100_X8_seq.sv"
`include "ddr_mul_wr_seq_bl4_100_X4_seq.sv"
`include "ddr_wr_bst_intlv_bl8_100_seq.sv"
`include "ddr_all_cmd_fsm_seq.sv"
`include "ddr_act_2_time_no_pre_btwn_seq.sv"
`include "ddr_write_dm_seq_bl8_100_seq.sv"

////////////////////anitha//////////////////
`include "ddr_mul_wr_intlv_bl8_100_X16_seq.sv"
`include "ddr_mul_wr_intlv_bl8_100_X8_seq.sv"
`include "ddr_mul_wr_intlv_bl8_100_X4_seq.sv"
`include "ddr_wr_basic_seq_bl4_100_seq.sv"
`include "ddr_w_ap_intlv_bl8_100_seq.sv"
`include "ddr_write_dm_intlv_bl4_100_seq.sv"
`include "ddr_wr_bst_seq_bl8_100_seq.sv"
`include "ddr_wr_without_act_err_seq.sv"
`include "ddr_wr_pd_seq_bl4_100_seq.sv"
`include "ddr_act4_wr_op_data_seq.sv"


/////////////HARSH//////////////////
`include "ddr_wr_basic_seq_bl8_100_seq.sv"
`include "ddr_wr_ovr_wr_data_seq.sv"
`include "ddr_mul_wr_seq_bl4_100_X16_seq.sv"
`include "ddr_wr_ap_seq_bl8_100_seq.sv"
`include "ddr_wr_ap_intlv_bl8_100_seq.sv"
`include "ddr_w_ap_seq_bl4_100_seq.sv"
`include "ddr_write_dm_intlv_bl8_100_seq.sv"
`include "ddr_wr_without_pre_seq.sv"


`include "DDR_sequencer.sv"
`include "DDR_driver.sv"
`include "DDR_monitor.sv"
`include "DDR_agent.sv"
`include "DDR_scoreboard.sv"
`include "DDR_subscriber.sv"
`include "DDR_env.sv"
`include "DDR_test.sv"
///////////////////////////////Jyothi/////////////////////
`include "ddr_wr_basic_intlv_bl8_100_test.sv"
`include "ddr_wr_sanity_seq_bl2_100_test.sv"
`include "ddr_wr_ap_seq_bl4_100_test.sv"
`include "ddr_w_ap_intlv_bl4_100_test.sv"
`include "ddr_mul_wr_intlv_bl4_100_X16_test.sv"
`include "ddr_mul_wr_intlv_bl4_100_X8_test.sv"
`include "ddr_mul_wr_intlv_bl4_100_X4_test.sv"
`include "ddr_wr_bst_seq_bl4_100_test.sv"
`include "ddr_act4_wr_pre_data_test.sv"
`include "ddr_rd_without_wr_bl2_100_test.sv"

//////////////////////parikshith///////////////////////
`include "ddr_wr_sanity_intlv_bl2_100_test.sv"
`include "ddr_wr_ap_intlv_bl4_100_test.sv"
`include "ddr_mul_wr_seq_bl8_100_X16_test.sv"
`include "ddr_mul_wr_seq_bl8_100_X8_test.sv"
`include "ddr_mul_wr_seq_bl8_100_X4_test.sv"
`include "ddr_time_par_test.sv"
`include "ddr_write_dm_seq_bl4_100_test.sv"
`include "ddr_wr_bst_intlv_bl4_100_test.sv"
`include "ddr_wr_auto_pre_bfr_data_cmp_test.sv"
//////////////////saketh////////////////////////
`include "ddr_wr_basic_intlv_bl4_100_test.sv"
`include "ddr_w_ap_seq_bl8_100_test.sv"
`include "ddr_mul_wr_seq_bl4_100_X8_test.sv"
`include "ddr_mul_wr_seq_bl4_100_X4_test.sv"
`include "ddr_wr_bst_intlv_bl8_100_test.sv"
`include "ddr_all_cmd_fsm_test.sv"
`include "ddr_act_2_time_no_pre_btwn_test.sv"
`include "ddr_write_dm_seq_bl8_100_test.sv"

///////////////anitha/////////////////////
`include "ddr_mul_wr_intlv_bl8_100_X16_test.sv"
 `include "ddr_mul_wr_intlv_bl8_100_X8_test.sv"
`include "ddr_mul_wr_intlv_bl8_100_X4_test.sv"
`include "ddr_wr_basic_seq_bl4_100_test.sv"
`include "ddr_w_ap_intlv_bl8_100_test.sv"
`include "ddr_write_dm_intlv_bl4_100_test.sv"
`include "ddr_wr_bst_seq_bl8_100_test.sv"
`include "ddr_wr_without_act_err_test.sv"
`include "ddr_act4_wr_op_data_test.sv"
`include "ddr_wr_pd_seq_bl4_100_test.sv"


///////////////HARSH//////////////////
`include "ddr_wr_basic_seq_bl8_100_test.sv"
`include "ddr_wr_ovr_wr_data_test.sv"
`include "ddr_mul_wr_seq_bl4_100_X16_test.sv"
`include "ddr_wr_ap_seq_bl8_100_test.sv"
`include "ddr_wr_ap_intlv_bl8_100_test.sv"
`include "ddr_w_ap_seq_bl4_100_test.sv"
`include "ddr_write_dm_intlv_bl8_100_test.sv"
`include "ddr_wr_without_pre_test.sv"

endpackage




