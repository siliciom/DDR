// ----------------------------------------------------------------------------------------------------
// Component    : ddr_time_Par_seq
// Test Owner   : Parikshith
//
// Description  :  Checking timing delays in ddr .
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=4, CL=2, Sequencial Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  checking proper delays  to verify basic DDR functionality.
// --------------------------------------------------------------------------------------------------------

class ddr_time_par_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_time_par_seq)

  DDR_seq_item seq;

  rand bit [0:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_time_par_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    // IDLE
    start_item(seq);
    if (!seq.randomize with { cmd == IDLE; })
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_IDLE", "inside idle", UVM_LOW)

    // MRS
    start_item(seq);
    if (!seq.randomize with {
          cmd    == MRS;
          cfg_bl == 4;
          cfg_cl == 2;
          cfg_bt == 0;
        })
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    /////////////////////////////////////////////////////////
    //  tRAS VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////tRAS VIOLATION///////////////");

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // ACTIVATE
    start_item(seq);
    if (!seq.randomize with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    // PRECHARGE immediately
    start_item(seq);
    if (!seq.randomize with {
          cmd  == PRECHARGE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_PRE", "random failed")
    finish_item(seq);

    /////////////////////////////////////////////////////////
    //  tWR VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////tWR VIOLATION///////////////");

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // ACTIVATE
    start_item(seq);
    if (!seq.randomize with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    // WRITE
    start_item(seq);
    if (!seq.randomize with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          auto_precharge == 0;
          dm             == 0;
        })
      `uvm_error("SEQ_WR", "random failed")
    finish_item(seq);

    // PRECHARGE immediately
    start_item(seq);
    if (!seq.randomize with {
          cmd  == PRECHARGE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_PRE", "random failed")
    finish_item(seq);

    /////////////////////////////////////////////////////////
    //  tWTR VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////tWTR VIOLATION///////////////");

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // ACTIVATE
    start_item(seq);
    if (!seq.randomize with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    // WRITE
    start_item(seq);
    if (!seq.randomize with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          auto_precharge == 0;
          dm             == 0;
        })
      `uvm_error("SEQ_WR", "random failed")

    col_addr.push_back(seq.addr);

    finish_item(seq);

    // READ immediately
    if (col_addr.size() > 0) begin

      pop_addr = col_addr.pop_front();

      start_item(seq);
      if (!seq.randomize with {
            cmd            == READ;
            cfg_bl         == 4;
            ba             == target_ba;
            addr           == pop_addr;
            auto_precharge == 0;
          })
        `uvm_error("SEQ_RD", "random failed")
      finish_item(seq);

    end

    /////////////////////////////////////////////////////////
    //  tRP VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////tRP VIOLATION///////////////");

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // PRECHARGE
    start_item(seq);
    if (!seq.randomize with {
          cmd  == PRECHARGE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_PRE", "random failed")
    finish_item(seq);

    // ACTIVATE immediately
    start_item(seq);
    if (!seq.randomize with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    /////////////////////////////////////////////////////////
    //  tMRD VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////tMRD VIOLATION///////////////");

    // MRS #1
    start_item(seq);
    if (!seq.randomize with {
          cmd    == MRS;
          cfg_bl == 4;
          cfg_cl == 2;
          cfg_bt == 1;
        })
      `uvm_error("SEQ_MRS1", "random failed")
    finish_item(seq);

    // MRS #2 immediately
    start_item(seq);
    if (!seq.randomize with {
          cmd    == MRS;
          cfg_bl == 8;
          cfg_cl == 3;
          cfg_bt == 0;
        })
      `uvm_error("SEQ_MRS2", "random failed")
    finish_item(seq);

    /////////////////////////////////////////////////////////
    //  tCL VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////TCL VIOLATION///////////////");

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "randomization failed")

    // ACTIVATE
    start_item(seq);
    if (!seq.randomize with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    // READ
    start_item(seq);

    pop_addr = (col_addr.size()) ? col_addr.pop_front() : 10'h0;

    if (!seq.randomize with {
          cmd            == READ;
          cfg_bl         == 4;
          ba             == target_ba;
          addr           == pop_addr;
          auto_precharge == 0;
        })
      `uvm_error("SEQ_RD", "random failed")

    finish_item(seq);

    // PRECHARGE immediately
    start_item(seq);
    if (!seq.randomize with {
          cmd  == PRECHARGE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_PRE", "random failed")
    finish_item(seq);

    /////////////////////////////////////////////////////////
    //  tDQSS VIOLATION
    /////////////////////////////////////////////////////////

    $display("////////////////TDQSS VIOLATION///////////////");

    start_item(seq);
    if (!seq.randomize with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          auto_precharge == 0;
        })
      `uvm_error("SEQ_WR", "random failed")
    finish_item(seq);

  endtask

endclass 


