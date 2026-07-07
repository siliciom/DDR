//=============================================================================
// Component    : ddr_write_dm_intlv_bl8_100_seq
// Test Owner   : Harsh Sharma
//
// Description  :
//   DDR Data Masking (DM) verification sequence. Targets Interleaved Burst Type with a configured Burst Length = 8. 
//
// Sequence Flow:
//     1. IDLE State
//     2. Mode Register Set (BL=8, CL=2, Interleaved Burst)
//     3. First Access Phase:
//        - ACTIVATE -> WRITE (dm_mode = 1) -> READ -> PRECHARGE
//     4. Second Access Phase:
//        - ACTIVATE -> WRITE (dm_mode = 2) -> READ (Auto-Precharge enabled)
//=============================================================================

class ddr_write_dm_intlv_bl8_100_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_write_dm_intlv_bl8_100_seq)

  //---------------------------------------------------------------------------
  // Sequence Variables & Trackers
  //---------------------------------------------------------------------------
  DDR_seq_item     seq;

  rand bit [1:0]   target_ba;
  rand bit [13:0]  target_row;

  bit [9:0]        col_addr[$]; // Queue to track generated column addresses
  bit [9:0]        pop_addr;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "ddr_write_dm_intlv_bl8_100_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Sequence Body Task
  //---------------------------------------------------------------------------
  virtual task body();
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ_START", "DATA MASK sequence", UVM_LOW)  

    // 1. IDLE State Execution
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);
       
    // 2. Mode Register Set (MRS Configuration)
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 1;}) 
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_MRS", $sformatf("MRS Configured: BL=%0d CL=%0d", seq.cfg_bl, seq.cfg_cl), UVM_LOW)

    // Randomize sequence bank and row targets
    if(!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")
	
    // ========================================================================
    // FIRST PHASE ACCESS (Data Mask Mode 1)
    // ========================================================================

    // ACTIVATE Bank
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // WRITE with Data Mask Mode 1
    `uvm_info("SEQ_WRITE", "Starting Randomized Writes", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 0; addr[2:0] == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
 			
    col_addr.push_back(seq.addr); 
    seq.dm_mode = 1;
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d dm_mode=%0d", seq.ba, seq.addr, seq.dm_mode), UVM_LOW)

    // Tracked READ
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)
    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
   
      if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; addr == pop_addr; auto_precharge == 0;}) begin
        `uvm_error("SEQ_RD", "random failed")
      end
    
      finish_item(seq);
      `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
    end

    // PRECHARGE Bank
    start_item(seq);
    if(!seq.randomize with {cmd == PRECHARGE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_PRECHARGE", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_PRE", $sformatf("=== BANK PRECHARGED === BA=%0d\n", target_ba), UVM_LOW)

    // ========================================================================
    // SECOND PHASE ACCESS (Data Mask Mode 2)
    // ========================================================================
				
    // Re-ACTIVATE Bank
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // WRITE with Data Mask Mode 2
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; addr[2:0] == 0; auto_precharge == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end

    col_addr.push_back(seq.addr);
    seq.dm_mode = 2;
    finish_item(seq);
		
    // Tracked READ with Data Mask Mode 2
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)
    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
   
      if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; addr == pop_addr; auto_precharge == 0;}) begin
        `uvm_error("SEQ_RD", "random failed")
      end
    
      finish_item(seq);
      `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
    end          

  endtask : body
endclass : ddr_write_dm_intlv_bl8_100_seq
