// ----------------------------------------------------------------------------------------------------
// Component    : ddr_act4_wr_op_data_seq
// Test Owner   : Anitha
//
// Description  :  Four active banks and write read operation  sequence for Burst Length = 4.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=4, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  write read  operation on four active banks  to verify basic DDR functionality.
// --------------------------------------------------------------------------------------------------------

class ddr_act4_wr_op_data_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_act4_wr_op_data_seq)

  DDR_seq_item seq;

 
  bit [9:0] col_addr[int][$];
  bit [9:0] pop_addr;

  int banks[4] = '{0, 1, 2, 3};
  int bank_row[int];

  function new(string name = "ddr_act4_wr_op_data_seq");
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
          cfg_bt == 1;
        })
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS", $sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    banks.shuffle();

    // ACTIVATE
    foreach (banks[i]) begin

      start_item(seq);

      if (!seq.randomize with {
            cmd == ACTIVATE;
            ba  == banks[i];
          })
        `uvm_error("SEQ_ACT", "random failed")

      bank_row[banks[i]] = seq.addr;

      finish_item(seq);

      `uvm_info("SEQ_ACT",$sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
    end

    // WRITE
    `uvm_info("SEQ_WRITE", "Starting Randomized Writes", UVM_LOW)

    banks.shuffle();

    foreach (banks[i]) begin

      start_item(seq);

      if (!seq.randomize() with {
            cmd == WRITE;
            cfg_bl == 4;
            ba == banks[i];
            addr[2:0] == 0;
            auto_precharge == 0;
            dm == 0;
          })
        `uvm_error("SEQ_WR", "random failed")

      col_addr[seq.ba].push_back(seq.addr);

      finish_item(seq);

      `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
    end

    // READ
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)

    banks.shuffle();

    foreach (banks[i]) begin
      if (col_addr.exists(banks[i]) &&
          col_addr[banks[i]].size() > 0) begin

        pop_addr = col_addr[banks[i]].pop_front();

        start_item(seq);

        if (!seq.randomize() with {
              cmd == READ;
              cfg_bl == 4;
              ba == banks[i];
              auto_precharge == 0;
              addr == pop_addr;
            })
          `uvm_error("SEQ_RD", "random failed")

        finish_item(seq);

        `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr), UVM_LOW)
      end
    end

  endtask

endclass






