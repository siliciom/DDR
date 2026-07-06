//=============================================================================
// Component    : ddr_wr_without_pre_seq
// Test Owner   : Harsh Sharma
//
// Description  :
//   An intentional error injection or boundary sequence testing a specific 
//   unsupported flow. It issues a second WRITE/READ command pair immediately 
//   following a PRECHARGE command without re-activating the bank.
//
// Sequence Flow:
//     1. IDLE State
//     2. Mode Register Set (BL=8, CL=2, Sequential Burst)
//     3. ACTIVATE Bank
//     4. WRITE 1 & READ 1 (Valid sequence on open bank)
//     5. PRECHARGE (Closes the active row)
//     6. WRITE 2 & READ 2 (Error Condition: Issued directly on the closed bank)
//=============================================================================

class ddr_wr_without_pre_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_wr_without_pre_seq)

  //---------------------------------------------------------------------------
  // Sequence Variables & Constraints
  //---------------------------------------------------------------------------
  DDR_seq_item     seq;
  
  rand bit [1:0]   target_ba;
  rand bit [13:0]  target_row;
  rand int         num;

  bit [9:0]        col_addr[$]; // Queue to track generated column addresses
  bit [9:0]        pop_addr;

  constraint counts { num inside {[2:5]}; }

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "ddr_wr_without_pre_seq");
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
       
    // 2. Mode Register Set (MRS Configuration)
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 0;}) 
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_MRS", $sformatf("MRS Configured: BL=%0d CL=%0d", seq.cfg_bl, seq.cfg_cl), UVM_LOW)

    // Randomize sequence bank and row targets
    if(!this.randomize())
      `uvm_error("SEQ_RAND", "Sequence body randomization failed")
	
    // 3. ACTIVATE Bank/Row
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // 4. WRITE 1 Operation
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 0; addr[2:0] == 0; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
 			
    col_addr.push_back(seq.addr); 
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 5. READ 1 Operation
    `uvm_info("SEQ_READ", $sformatf("Starting %0d Tracking Reads", num), UVM_LOW)
    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
   
      if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; addr == pop_addr; auto_precharge == 0;}) begin
        `uvm_error("SEQ_RD", "random failed")
      end
    
      finish_item(seq);
      `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
    end      
	
    // 6. PRECHARGE Command (Closes the open row)
    start_item(seq);
    if(!seq.randomize with {cmd == PRECHARGE; ba == target_ba; addr == target_row;})
      `uvm_error("SEQ_PRECHARGE", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_PRE", $sformatf("=== BANK PRECHARGED === BA=%0d\n", target_ba), UVM_LOW)

    // 7. WRITE 2 Operation (Error injection: Issued on a precharged/closed bank)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 0; addr[2:0] == 0; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
 			
    col_addr.push_back(seq.addr); 
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
		
    // 8. READ 2 Operation
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
endclass : ddr_wr_without_pre_seq
