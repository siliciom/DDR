//------------------------------------------------------------------------------
// Component    : ddr_act_2_time_no_pre_btwn_seq
// Test Owner   : saketh
//
// Description  :
//   DDR sequence to verify back-to-back ACTIVATE commands on the same bank
//   without PRECHARGE in between.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=8, CL=2)
//     3. ACTIVATE (Row1)
//     4. WRITE
//     5. ACTIVATE again to same bank without PRECHARGE
//
//   This sequence validates tRC/tRAS constraints and illegal ACT-to-ACT
//   behavior without intervening PRECHARGE.
//------------------------------------------------------------------------------

class ddr_act_2_time_no_pre_btwn_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_act_2_time_no_pre_btwn_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_act_2_time_no_pre_btwn_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    // IDLE
    start_item(seq);
    if (!seq.randomize() with { cmd == IDLE; }) `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_IDLE", "inside idle", UVM_LOW)

    // MRS
    start_item(seq);
    if (!seq.randomize() with { cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 1; })
	    `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS",
              $sformatf("MRS cfg_bl=%0d cfg_cl=%0d cfg_bt=%0b",seq.cfg_bl, seq.cfg_cl, seq.cfg_bt),UVM_LOW)

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // FIRST ACTIVATE
    start_item(seq);
    if (!seq.randomize() with { cmd == ACTIVATE; ba == target_ba; addr == target_row; })
	    `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_ACT",$sformatf("=== BANK ACTIVATED FIRST TIME === BA=%0d ROW=%0d",seq.ba, seq.addr),UVM_LOW)

    // WRITE
    start_item(seq);
    if (!seq.randomize() with { cmd == WRITE; cfg_bl == 8; ba == target_ba; addr[2:0] == 0; auto_precharge == 0; dm == 0; })
	    `uvm_error("SEQ_WR", "random failed")

    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA",
              $sformatf("WRITE -> BA=%0d COL_ADDR=%0d",
                        seq.ba, seq.addr),
              UVM_LOW)

    // SECOND ACTIVATE (NO PRECHARGE IN BETWEEN)
    start_item(seq);
    if (!seq.randomize() with { cmd == ACTIVATE; ba == target_ba; addr == target_row;})
	    `uvm_error("SEQ_ACT2", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_ACT2",
              $sformatf("=== BANK ACTIVATED SECOND TIME === BA=%0d ROW=%0d",
                        seq.ba, seq.addr),
              UVM_LOW)

  endtask

endclass
