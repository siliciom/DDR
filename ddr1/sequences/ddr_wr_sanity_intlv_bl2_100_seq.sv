//=============================================================================
// Component    : ddr_wr_sanity_intlv_bl2_100_seq
// Test Owner   : Parikshith S D
//
// Description  :
//   Basic DDR WRITE/READ sanity sequence for Burst Length = 2 and 
//   Interleaved Burst Type (`cfg_bt == 1`).
//
// Sequence Flow:
//     1. IDLE State
//     2. Mode Register Set (BL=2, CL=2, Interleaved Burst)
//     3. ACTIVATE (Bank 1, Row 25)
//     4. WRITE    (Bank 1, Column 8, Auto-Precharge disabled)
//     5. READ     (Bank 1, Column 8, Auto-Precharge disabled)
//
//   This sequence performs a basic targeted write followed by a read from the
//   same bank and column to verify interleaved short burst functionality.
//=============================================================================

class ddr_wr_sanity_intlv_bl2_100_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_wr_sanity_intlv_bl2_100_seq)

  //---------------------------------------------------------------------------
  // Sequence Variables
  //---------------------------------------------------------------------------
  DDR_seq_item seq;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "ddr_wr_sanity_intlv_bl2_100_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Sequence Body Task
  //---------------------------------------------------------------------------
  task body();
    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ", "Generating transaction", UVM_LOW)
			
    // 1. IDLE State Execution
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_IDLE", "inside idle", UVM_LOW)
	   
    // 2. Mode Register Set (MRS Configuration: Interleaved Mode)
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 2; cfg_cl == 2; cfg_bt == 1;})
      `uvm_error("SEQ_MRS", "random failed")
    finish_item(seq);
    `uvm_info("SEQ_MRS", $sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b", seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    // 3. ACTIVATE Bank/Row (BA=1, ROW=25)
    start_item(seq);
    assert(seq.randomize with {cmd == ACTIVATE; ba == 1; addr == 25;});
    finish_item(seq);
    `uvm_info("SEQ", $sformatf("Basic Sanity ACT BL2 BA=%0d ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
     
    // 4. WRITE Operation (Target Column = 8)
    start_item(seq);
    assert(seq.randomize with {cmd == WRITE; cfg_bl == 2; ba == 1; addr == 8; dm == 0; auto_precharge == 0;});
    finish_item(seq);
    `uvm_info("SEQ", $sformatf("Basic Sanity BL2 BA=%0d ADDR=%0d DATA=%0d", seq.ba, seq.addr, seq.dq), UVM_LOW)
		
    // 5. READ Operation (Verify Column = 8)
    start_item(seq);
    assert(seq.randomize with {cmd == READ; cfg_bl == 2; ba == 1; addr == 8; auto_precharge == 0;});
    finish_item(seq);
    `uvm_info("SEQ", $sformatf("Basic Wr READ BL2 BA=%0d ADDR=%0d DATA=%0d", seq.ba, seq.addr, seq.dq), UVM_LOW)

  endtask : body

endclass : ddr_wr_sanity_intlv_bl2_100_seq
