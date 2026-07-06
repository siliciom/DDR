// -------------------------------------------------------------------------------------------------------------------------------
// Component    : ddr_wr_bst_seq_bl8_100_seq
// Test Owner   : Anitha
//
// Description  :  Burst terminate  sequence for Burst Length = 8.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=8, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  burst termination operation by issuing bst command after read  to verify basic DDR functionality.
// ---------------------------------------------------------------------------------------------------------------------------------

class ddr_wr_bst_seq_bl8_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_bst_seq_bl8_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_wr_bst_seq_bl8_100_seq");
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
          cfg_bl == 8;
          cfg_cl == 2;
          cfg_bt == 0;
        })
      `uvm_error("SEQ_MRS", "random failed")

    finish_item(seq);

    `uvm_info("SEQ_MRS", $sformatf("MRS BL=%0d CL=%0d BT=%0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    repeat (5) begin

      if (!this.randomize())
        `uvm_error("SEQ_RAND", "Sequence body randomization failed")

      // ACTIVATE
      start_item(seq);

      if (!seq.randomize() with {
            cmd  == ACTIVATE;
            ba   == target_ba;
            addr == target_row;
          })
        `uvm_error("SEQ_ACT", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_ACT", $sformatf("ACTIVATE BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)

      // WRITE
      `uvm_info("SEQ_WRITE", "Starting WRITE transaction", UVM_LOW)

      start_item(seq);

      if (!seq.randomize() with {
            cmd            == WRITE;
            cfg_bl         == 8;
            ba             == target_ba;
            addr[2:0]      == 0;
            auto_precharge == 0;
            dm             == 0;
          })
        `uvm_error("SEQ_WR", "random failed")

      col_addr.push_back(seq.addr);

      finish_item(seq);

      `uvm_info("SEQ_WR_DATA", $sformatf("WRITE BA=%0d COL=%0d", seq.ba, seq.addr), UVM_LOW)

      // READ
      `uvm_info("SEQ_READ", "Starting READ transaction", UVM_LOW)

      if (col_addr.size() > 0) begin

        start_item(seq);

        pop_addr = col_addr.pop_front();

        if (!seq.randomize() with {
              cmd            == READ;
              cfg_bl         == 8;
              ba             == target_ba;
              auto_precharge == 0;
              addr           == pop_addr;
              bst_mode       == 1;
            })
          `uvm_error("SEQ_RD", "random failed")

        finish_item(seq);

        `uvm_info("SEQ_RD_DATA", $sformatf("READ BA=%0d COL=%0d", seq.ba, seq.addr), UVM_LOW)

      end

      // NOPs
      repeat (2) begin

        start_item(seq);

        if (!seq.randomize() with { cmd == NOP; })
          `uvm_error("SEQ_NOP", "random failed")

        finish_item(seq);

        `uvm_info("SEQ_NOP", "NOP issued", UVM_LOW)

      end

      // BST
      start_item(seq);

      if (!seq.randomize() with { cmd == BST; })
        `uvm_error("SEQ_BST", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_BST", "Burst Terminate Issued", UVM_LOW)

    end

  endtask

endclass
