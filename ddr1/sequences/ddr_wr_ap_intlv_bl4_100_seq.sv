//------------------------------------------------------------------------------
// Component    : ddr_wr_ap_intlv_bl4_100_seq
// Test Owner   : Parikshith
// Description  :
//   DDR WRITE Auto-Precharge + READ interleaved sequence (BL=4).
//
//   Sequence Flow:
//     IDLE → MRS → ACTIVATE → WRITE (Auto Precharge) → READ
//
//   This sequence verifies WRITE with Auto Precharge followed by READ
//   operations using BL=4 interleaved access patterns.
//------------------------------------------------------------------------------

class ddr_wr_ap_intlv_bl4_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_ap_intlv_bl4_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_wr_ap_intlv_bl4_100_seq");
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

    `uvm_info("SEQ_IDLE", "inside idle", UVM_LOW)

    // MRS
    start_item(seq);
    assert(seq.randomize() with { cmd == MRS; cfg_bl == 4; cfg_cl == 2; cfg_bt == 1; });
    finish_item(seq);

    `uvm_info("SEQ_MRS",
              $sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    if (!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")

    // ACTIVATE
    start_item(seq);
    if (!seq.randomize() with { cmd == ACTIVATE; ba == target_ba; addr == target_row; })
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_ACT",
              $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d",seq.ba, seq.addr),UVM_LOW)

    // WRITE (Auto Precharge)
    `uvm_info("SEQ_WRITE", "Starting Randomized Writes", UVM_LOW)

    start_item(seq);
    if (!seq.randomize() with { cmd == WRITE; cfg_bl == 4; ba == target_ba; addr[2:0] == 0; auto_precharge == 0; dm == 0; })
      `uvm_error("SEQ_WR", "random failed")

    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr),UVM_LOW)

    // READ
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)

    if (col_addr.size() > 0) begin

      start_item(seq);

      pop_addr = col_addr.pop_front();

      if (!seq.randomize() with { cmd == READ; cfg_bl == 4; ba == target_ba; addr == pop_addr; auto_precharge == 1; })
        `uvm_error("SEQ_RD", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr),UVM_LOW)
    end

  endtask

endclass
