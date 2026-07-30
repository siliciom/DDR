// ------------------------------------------------------------------------
// Component    : ddr_wr_without_act_err_seq
// Test Owner   : Anitha
//
// Description  :  Write without active sequence for Burst Length = 4.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=4, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  write operation without active command  to verify basic DDR functionality.
// ------------------------------------------------------------------------

class ddr_wr_without_act_err_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_without_act_err_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_wr_without_act_err_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    // IDLE
    start_item(seq);

    if (!seq.randomize() with { cmd == IDLE; })
      `uvm_error("SEQ_IDLE", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_IDLE", "Inside IDLE", UVM_LOW)

    // MRS
    start_item(seq);

    if (!seq.randomize() with {
          cmd    == MRS;
          cfg_bl == 4;
          cfg_cl == 2;
          cfg_bt == 0;
        })
      `uvm_error("SEQ_RAND_MRS", "Sequence body randomization failed")

    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS BL=%0d CL=%0d BT=%0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt),UVM_LOW)

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // WRITE WITHOUT ACTIVATE (Error Scenario)
    start_item(seq);

    if (!seq.randomize() with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          addr[2:0]      == 0;
          auto_precharge == 0;
          dm             == 0;
        })
    begin
      `uvm_error("SEQ_WR", "WRITE issued without ACTIVATE command")
    end

    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA",$sformatf("WRITE BA=%0d COL=%0d",seq.ba, seq.addr), UVM_LOW)

  endtask

endclass

