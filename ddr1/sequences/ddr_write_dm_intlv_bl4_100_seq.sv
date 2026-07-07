// ------------------------------------------------------------------------
// Component    : ddr_write_dm_intlv_bl4_100_seq
// Test Owner   : Anitha
//
// Description  :  WRITE with data mask  sequence for Burst Length = 4.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=4, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  write with datamask by masking dm high operation from
// same bank and column to verify basic DDR functionality.
// ------------------------------------------------------------------------


class ddr_write_dm_intlv_bl4_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_write_dm_intlv_bl4_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_write_dm_intlv_bl4_100_seq");
    super.new(name);
  endfunction

  virtual task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ_START", "DATA MASK sequence", UVM_LOW)

    //-------------------------------------------------
    // IDLE
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with { cmd == IDLE; })
      `uvm_error("SEQ_IDLE", "random failed")

    finish_item(seq);

    //-------------------------------------------------
    // MRS
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with {
          cmd    == MRS;
          cfg_bl == 4;
          cfg_cl == 2;
          cfg_bt == 1;
        })
      `uvm_error("SEQ_MRS", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_MRS", $sformatf("MRS Configured: BL=%0d CL=%0d", seq.cfg_bl, seq.cfg_cl), UVM_LOW)

    //-------------------------------------------------
    // Randomize sequence-level parameters
    //-------------------------------------------------
    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    //-------------------------------------------------
    // ACTIVATE
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_ACT", $sformatf("BANK ACTIVATED BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)

    //-------------------------------------------------
    // WRITE (DM mode = 1)
    //-------------------------------------------------
    `uvm_info("SEQ_WRITE", "Starting Randomized Writes", UVM_LOW)

    start_item(seq);

    if (!seq.randomize() with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          auto_precharge == 0;
          addr[2:0]      == 0;
        })
      `uvm_error("SEQ_WR", "random failed")

    col_addr.push_back(seq.addr);
    seq.dm_mode = 1;

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE BA=%0d COL=%0d DM_MODE=%0d", seq.ba, seq.addr, seq.dm_mode), UVM_LOW)

    //-------------------------------------------------
    // READ
    //-------------------------------------------------
    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)

    if (col_addr.size() > 0) begin

      start_item(seq);

      pop_addr = col_addr.pop_front();

      if (!seq.randomize() with {
            cmd            == READ;
            cfg_bl         == 4;
            ba             == target_ba;
            addr           == pop_addr;
            auto_precharge == 0;
          })
        `uvm_error("SEQ_RD", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_RD_DATA", $sformatf("READ BA=%0d COL=%0d", seq.ba, seq.addr), UVM_LOW)

    end

    //-------------------------------------------------
    // PRECHARGE
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with {
          cmd  == PRECHARGE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_PRECHARGE", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_PRE", $sformatf("BANK PRECHARGED BA=%0d", target_ba), UVM_LOW)

    //-------------------------------------------------
    // ACTIVATE AGAIN
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with {
          cmd  == ACTIVATE;
          ba   == target_ba;
          addr == target_row;
        })
      `uvm_error("SEQ_ACT", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_ACT", $sformatf("BANK ACTIVATED BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)

    //-------------------------------------------------
    // WRITE (DM mode = 2)
    //-------------------------------------------------
    start_item(seq);

    if (!seq.randomize() with {
          cmd            == WRITE;
          cfg_bl         == 4;
          ba             == target_ba;
          addr[2:0]      == 0;
          auto_precharge == 0;
        })
      `uvm_error("SEQ_WR", "random failed")

    col_addr.push_back(seq.addr);
    seq.dm_mode = 2;

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE BA=%0d COL=%0d DM_MODE=%0d", seq.ba, seq.addr, seq.dm_mode), UVM_LOW)

    //-------------------------------------------------
    // READ (Auto-precharge enabled)
    //-------------------------------------------------
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)

    if (col_addr.size() > 0) begin

      start_item(seq);

      pop_addr = col_addr.pop_front();

      if (!seq.randomize() with {
            cmd            == READ;
            cfg_bl         == 4;
            ba             == target_ba;
            addr           == pop_addr;
            auto_precharge == 1;
          })
        `uvm_error("SEQ_RD", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_RD_DATA", $sformatf("READ BA=%0d COL=%0d", seq.ba, seq.addr), UVM_LOW)

    end

  endtask

endclass
