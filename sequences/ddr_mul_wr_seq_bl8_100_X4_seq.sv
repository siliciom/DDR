// Component    : ddr_mul_wr_seq_bl8_100_X4_seq
// Test Owner   : Parikshith
//
// Description  :
//   DDR multiple WRITE/READ sequence for Sequential Burst Length = 8 (x4).
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=8, CL=2, Sequential Burst)
//     3. Repeat twice:
//          - Randomize target Bank and Row
//          - ACTIVATE
//          - Random number of WRITE transactions (2 to 5)
//          - READ back all written locations
//          - PRECHARGE
//
//   This sequence verifies multiple write/read operations with BL8
//   sequential burst on an x4 DDR device.
//

class ddr_mul_wr_seq_bl8_100_X4_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_mul_wr_seq_bl8_100_X4_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  rand int num;

  // Number of WRITE/READ transactions
  constraint counts {
    num inside {[2:5]};
  }

  function new(string name = "ddr_mul_wr_seq_bl8_100_X4_seq");
    super.new(name);
  endfunction

  task body;

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ_START","Multiple write and read with randomize vaues",UVM_LOW)

    //-----------------------------------------------------------------------
    // IDLE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE","random failed")
    finish_item(seq);

    //-----------------------------------------------------------------------
    // Mode Register Set (MRS)
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize with {cmd == MRS; cfg_bl == 8; cfg_cl == 2; cfg_bt == 0;})
      `uvm_error("SEQ_MRS","random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS Configured: BL=%0d CL=%0d",seq.cfg_bl,seq.cfg_cl),UVM_LOW)

    //-----------------------------------------------------------------------
    // Repeat ACTIVATE -> WRITE -> READ -> PRECHARGE twice
    //-----------------------------------------------------------------------
    repeat(2) begin

      //---------------------------------------------------------------------
      // Randomize Target Bank and Row
      //---------------------------------------------------------------------
      if(!this.randomize())
        `uvm_error("SEQ_RAND","Sequence body randomization failed")

      //---------------------------------------------------------------------
      // ACTIVATE Command
      //---------------------------------------------------------------------
      start_item(seq);
      if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
        `uvm_error("SEQ_ACT","random failed")
      finish_item(seq);

      `uvm_info("SEQ_ACT",$sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d",seq.ba,seq.addr),UVM_LOW)

      //---------------------------------------------------------------------
      // WRITE Commands
      //---------------------------------------------------------------------
      `uvm_info("SEQ_WRITE",$sformatf("Starting %0d Randomized Writes",num),UVM_LOW)

      repeat(num) begin

        start_item(seq);
        if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba; auto_precharge == 0; addr[2:0] == 0; dm == 0;}) begin
          `uvm_error("SEQ_WR","random failed")
        end

        // Store WRITE column address for READ operation
        col_addr.push_back(seq.addr);

        finish_item(seq);

        `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL_ADDR=%0d",seq.ba,seq.addr),UVM_LOW)
      end

      //---------------------------------------------------------------------
      // READ Commands
      //---------------------------------------------------------------------
      `uvm_info("SEQ_READ",$sformatf("Starting %0d Tracking Reads",num),UVM_LOW)

      repeat(num) begin
        if (col_addr.size() > 0) begin

          start_item(seq);

          // Retrieve previously stored WRITE column address
          pop_addr = col_addr.pop_front();

          if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; addr == pop_addr; auto_precharge == 0;}) begin
            `uvm_error("SEQ_RD","random failed")
          end

          finish_item(seq);

          `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba,seq.addr),UVM_LOW)
        end
      end

      //---------------------------------------------------------------------
      // PRECHARGE Command
      //---------------------------------------------------------------------
      start_item(seq);
      if(!seq.randomize with {cmd == PRECHARGE; ba == target_ba; addr == target_row;})
        `uvm_error("SEQ_PRECHARGE","random failed")
      finish_item(seq);

      `uvm_info("SEQ_PRE",$sformatf("=== BANK PRECHARGED === BA=%0d\n",target_ba),UVM_LOW)

    end // repeat(2)

  endtask

endclass
