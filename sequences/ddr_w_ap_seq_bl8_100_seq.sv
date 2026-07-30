//==============================================================================
// Component    : ddr_w_ap_seq_bl8_100_seq
// Test Owner   : saketh
//
// Description  :
//  Basic DDR WRITE with auto precharge  sequence for Burst Length = 8.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=8, CL=2, seq Burst)
//     3. ACTIVATE
//     4. WRITE
// DDR WRITE sequence with Auto-Precharge for Burst Length = 8.
//Performs an initial sequence setup (IDLE, MRS), activates a 
//target row, and executes a randomized WRITE transaction with 
//Auto-Precharge enabled.
//==============================================================================

class ddr_w_ap_seq_bl8_100_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_w_ap_seq_bl8_100_seq)

  // Sequence Variables & Tracking Queues
  DDR_seq_item seq;
  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;
  
  // Constructor
  function new(string name ="ddr_w_ap_seq_bl8_100_seq");
    super.new(name);
  endfunction

  // Sequence Body Task
  task body();
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    // IDLE Command
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE","random failed")
    finish_item(seq);
    `uvm_info("SEQ_IDLE","inside idle",UVM_LOW)

    // Mode Register Set (MRS)
    start_item(seq);
    assert(seq.randomize with {cmd == MRS; cfg_bl==8; cfg_cl==2; cfg_bt==0;});
    finish_item(seq);
    `uvm_info("SEQ",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b",seq.cfg_bl,seq.cfg_cl,seq.cfg_bt),UVM_LOW)

    // Sequence Body Randomization
    if(!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")
	
    // ACTIVATE Command
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // WRITE Command (with Auto-Precharge)
    `uvm_info("SEQ_WRITE", $sformatf("Starting Randomized Writes"), UVM_LOW)

    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 1; dm == 0;}) begin
      `uvm_error("SEQ_WR","random failed")
    end
    
    col_addr.push_back(seq.addr); 
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

  endtask
endclass
