// Component    : ddr_w_ap_intlv_bl4_100_seq
// Test Owner   : Siva Jyothi
//
// Description  :
//   Basic DDR WRITE sequence with Auto Precharge enabled, using
//   Interleaved Burst Length = 4.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=4, CL=2, Interleaved Burst)
//     3. Randomize target Bank and Row
//     4. ACTIVATE
//     5. WRITE (Auto Precharge Enabled)
//
//   This sequence verifies WRITE Auto Precharge functionality in
//   BL4 Interleaved Burst mode.
//

class ddr_w_ap_intlv_bl4_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_w_ap_intlv_bl4_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;


  function new(string name ="ddr_w_ap_intlv_bl4_100_seq");
    super.new(name);
  endfunction


  task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    //-----------------------------------------------------------------------
    // IDLE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE","random failed")
    finish_item(seq);

    `uvm_info("SEQ_IDLE","inside idle",UVM_LOW)


    //-----------------------------------------------------------------------
    // Mode Register Set (MRS)
    // BL = 4
    // CL = 2
    // Interleaved Burst
    //-----------------------------------------------------------------------
    start_item(seq);
    assert(seq.randomize with {cmd == MRS; cfg_bl==4; cfg_cl==2; cfg_bt==1;});
    finish_item(seq);

    `uvm_info("SEQ",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b",seq.cfg_bl,seq.cfg_cl,seq.cfg_bt),UVM_LOW)


    //-----------------------------------------------------------------------
    // Randomize Target Bank and Row
    //-----------------------------------------------------------------------
    if(!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")


    //-----------------------------------------------------------------------
    // ACTIVATE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    `uvm_info("SEQ_ACT",$sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d",seq.ba, seq.addr),UVM_LOW)


    //-----------------------------------------------------------------------
    // WRITE Command (Auto Precharge Enabled)
    //-----------------------------------------------------------------------
    `uvm_info("SEQ_WRITE",$sformatf("Starting Randomized Writes"), UVM_LOW)

    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 4; ba == target_ba; addr[2:0]==0;auto_precharge == 1; dm == 0;}) begin
      `uvm_error("SEQ_WR","random failed")
    end

    // Store WRITE column address
    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr), UVM_LOW)

  endtask

endclass
