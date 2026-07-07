//=============================================================================
// Component    : ddr_wr_ap_intlv_bl8_100_seq
// Test Owner   : Harsh Sharma
//
// Description  :
//   DDR WRITE followed by a READ sequence with Interleaved Burst Type (`cfg_bt == 1`) and Auto-Precharge enabled on
//   the READ command for Burst Length = 8.
//
// Sequence Flow:
//     1. IDLE State
//     2. Mode Register Set (BL=8, CL=2, Interleaved Burst Type)
//     3. Randomize Bank/Row addresses locally
//     4. ACTIVATE Bank
//     5. WRITE (Auto-precharge disabled, tracks generated column address)
//     6. READ  (Auto-precharge enabled, pops address, targets interleaved burst,
//               and triggers automatic bank closure after burst completion)
//=============================================================================

class ddr_wr_ap_intlv_bl8_100_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_wr_ap_intlv_bl8_100_seq)

  //---------------------------------------------------------------------------
  // Sequence Variables & Trackers
  //---------------------------------------------------------------------------
  DDR_seq_item     seq;
  
  rand bit [1:0]   target_ba;
  rand bit [13:0]  target_row;

  bit [9:0]        col_addr[$]; // Queue to track written column addresses
  bit [9:0]        pop_addr;
 
  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "ddr_wr_ap_intlv_bl8_100_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Sequence Body Task
  //---------------------------------------------------------------------------
  task body;
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ_START", "Multiple write and read with randomize values", UVM_LOW)  

    // 1. IDLE State Execution
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);
       
    // 2. Mode Register Set (MRS Configuration: Interleaved Burst Type Enabled)
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 1;}) 
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_MRS", $sformatf("MRS Configured: BL=%0d CL=%0d BT=INTERLEAVED", seq.cfg_bl, seq.cfg_cl), UVM_LOW)

    // Randomize sequence bank and row targets
    if(!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")
	
    // 3. ACTIVATE Bank/Row
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // 4. WRITE Operation (Auto-Precharge = 0)
    `uvm_info("SEQ_WRITE", "Starting Randomized Writes", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 0; addr[2:0] == 0; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
 			
    col_addr.push_back(seq.addr); 
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 5. READ Operation with Auto-Precharge (Auto-Precharge = 1)
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)
    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
   
      if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; addr == pop_addr; auto_precharge == 1;}) begin
        `uvm_error("SEQ_RD", "random failed")
      end
    
      finish_item(seq);
      `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
    end        

  endtask : body
endclass : ddr_wr_ap_intlv_bl8_100_seq
