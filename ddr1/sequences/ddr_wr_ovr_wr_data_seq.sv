//=============================================================================
// Component    : ddr_wr_ovr_wr_data_seq
// Test Owner   : Harsh Sharma
//
// Description  :
//   DDR write overwrite sequence. This sequence tests the memory's ability 
//   to handle back-to-back writes, including overwriting a previously written 
//   address space (Address 8) before executing read checks.
//
// Sequence Flow:
//     1. Mode Register Set (BL=8, CL=2, Sequential Burst)
//     2. IDLE State
//     3. ACTIVATE (Bank 1, Row 20)
//     4. WRITE 1  (Bank 1, Column 8)
//     5. WRITE 2  (Bank 1, Column 16)
//     6. WRITE 3  (Bank 1, Column 8 - Overwrites data from WRITE 1)
//     7. READ 1   (Bank 1, Column 8 - Verifies overwritten data)
//     8. READ 2   (Bank 1, Column 16)
//=============================================================================

class ddr_wr_ovr_wr_data_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_wr_ovr_wr_data_seq)

  //---------------------------------------------------------------------------
  // Sequence Variables & Interfaces
  //---------------------------------------------------------------------------
  DDR_seq_item         seq;
  virtual DDR_interface vif;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "ddr_wr_ovr_wr_data_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Sequence Body Task
  //---------------------------------------------------------------------------
  task body;
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ_START", "Multiple write and read with randomize values", UVM_LOW)  
         
    // 1. Mode Register Set (MRS Configuration)
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 0;}) 
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_MRS", $sformatf("MRS Configured: BL=%0d CL=%0d", seq.cfg_bl, seq.cfg_cl), UVM_LOW)

    // 2. IDLE State Execution
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);
	 
    // 3. ACTIVATE Bank/Row (BA=1, ROW=20)
    start_item(seq);
    if(!seq.randomize with {cmd == ACTIVATE; ba == 1; addr == 20;})
      `uvm_error("SEQ_ACT", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
  
    // 4. WRITE 1 Operation (Target Column = 8)
    `uvm_info("SEQ_WRITE1", "Starting Randomized Writes", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == 1; auto_precharge == 0; addr == 8; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 5. WRITE 2 Operation (Target Column = 16)
    `uvm_info("SEQ_WRITE2", "Starting Randomized Writes", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == 1; auto_precharge == 0; addr == 16; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 6. WRITE 3 Operation (Overwrite Target Column = 8)
    `uvm_info("SEQ_WRITE3", "Starting Randomized Writes", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == 1; auto_precharge == 0; addr == 8; dm == 0;}) begin
      `uvm_error("SEQ_WR", "random failed")
    end
    finish_item(seq);
    `uvm_info("SEQ_WR_DATA", $sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 7. READ 1 Operation (Verify Overwritten Column = 8)
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == 1; addr == 8; auto_precharge == 0;}) begin
      `uvm_error("SEQ_RD", "random failed")
    end
    finish_item(seq);
    `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

    // 8. READ 2 Operation (Verify Column = 16)
    `uvm_info("SEQ_READ", "Starting Tracking Reads", UVM_LOW)
    start_item(seq);
    if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == 1; addr == 16; auto_precharge == 0;}) begin
      `uvm_error("SEQ_RD", "random failed")
    end
    finish_item(seq);
    `uvm_info("SEQ_RD_DATA", $sformatf("READ -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)

  endtask : body
endclass : ddr_wr_ovr_wr_data_seq
