// ------------------------------------------------------------------------
// Component    : ddr_w_ap_intlv_bl8_100_seq
// Test Owner   : Anitha
//
// Description  :  WRITE with autoprecharge sequence for Burst Length = 8.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=8, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  write with autoprecharge operation from
// same bank and column to verify basic DDR functionality.
// ------------------------------------------------------------------------

class ddr_w_ap_intlv_bl8_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_w_ap_intlv_bl8_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  sel_ba;
  rand bit [13:0] sel_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_w_ap_intlv_bl8_100_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ_START","WRITE AP with randomized values",UVM_LOW)

    // IDLE
    start_item(seq);

    if (!seq.randomize() with { cmd == IDLE; })
      `uvm_error("SEQ_IDLE", "Randomization failed")

    finish_item(seq);

    // MRS
    start_item(seq);

    if (!seq.randomize() with {
          cmd    == MRS;
          cfg_bl == 8;
          cfg_cl == 2;
          cfg_bt == 1;
        })
      `uvm_error("SEQ_MRS", "Randomization failed")

    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS Configured: BL=%0d CL=%0d",seq.cfg_bl, seq.cfg_cl),UVM_LOW)

    if (!this.randomize())
      `uvm_error("SEQ_RAND","Sequence body randomization failed")

    // ACTIVATE
    start_item(seq);

    if (!seq.randomize() with {
          cmd  == ACTIVATE;
          ba   == sel_ba;
          addr == sel_row;
        })
      `uvm_error("SEQ_ACT", "Randomization failed")

    finish_item(seq);

    `uvm_info("SEQ_ACT",$sformatf("BANK ACTIVATED BA=%0d ROW=%0d", seq.ba, seq.addr),UVM_LOW)

    // WRITE
    start_item(seq);

    if (!seq.randomize() with {
          cmd            == WRITE;
          cfg_bl         == 8;
          ba             == sel_ba;
          addr[2:0]      == 0;
          auto_precharge == 1;
          dm             == 0;
        })
    begin
      `uvm_error("SEQ_WR", "Randomization failed")
    end

    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL=%0d",seq.ba, seq.addr),UVM_LOW)

  endtask

endclass
