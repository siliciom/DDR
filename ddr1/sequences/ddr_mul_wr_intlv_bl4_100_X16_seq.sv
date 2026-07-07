// Component    : ddr_mul_wr_intlv_bl4_100_X16_seq
// Test Owner   : Siva Jyothi
//
// Description  :
//   DDR multiple WRITE/READ sequence for Interleaved Burst Length = 4 (x16).
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=4, CL=2, Interleaved Burst)
//     3. Randomize target Bank and Row
//     4. Repeat twice:
//          - ACTIVATE
//          - Random number of WRITE transactions (2 to 5)
//          - READ back all written locations
//          - PRECHARGE
//
//   This sequence verifies multiple write/read operations with BL4
//   interleaved burst on an x16 DDR device.
//

class ddr_mul_wr_intlv_bl4_100_X16_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_mul_wr_intlv_bl4_100_X16_seq)

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


  function new(string name ="ddr_mul_wr_intlv_bl4_100_X16_seq");
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
    // Repeat ACTIVATE -> WRITE -> READ -> PRECHARGE twice
    //-----------------------------------------------------------------------
    repeat(2) begin

      //---------------------------------------------------------------------
      // ACTIVATE Command
      //---------------------------------------------------------------------
      start_item(seq);
      if(!seq.randomize with {cmd == ACTIVATE; ba == target_ba; addr == target_row;})
        `uvm_error("SEQ_ACT","random failed")
      finish_item(seq);

      `uvm_info("SEQ_ACT", $sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d",seq.ba, seq.addr),UVM_LOW)


      //---------------------------------------------------------------------
      // WRITE Commands
      //---------------------------------------------------------------------
      `uvm_info("SEQ_WRITE",$sformatf("Starting %0d Randomized Writes", num),UVM_LOW)

      repeat(num) begin

        start_item(seq);
        if(!seq.randomize with {cmd == WRITE; cfg_bl == 4; ba == target_ba;addr[2:0]==0; auto_precharge == 0; dm == 0;}) begin
          `uvm_error("SEQ_WR","random failed")
        end

        // Store WRITE column address for READ operation
        col_addr.push_back(seq.addr);

        finish_item(seq);

        `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr),UVM_LOW)
      end


      //---------------------------------------------------------------------
      // READ Commands
      //---------------------------------------------------------------------
      `uvm_info("SEQ_READ",$sformatf("Starting %0d Tracking Reads", num), UVM_LOW)

      repeat(num) begin
        if (col_addr.size() > 0) begin

          start_item(seq);

          // Retrieve previously stored column address
          pop_addr = col_addr.pop_front();

          if(!seq.randomize with {cmd == READ; cfg_bl == 4; ba == target_ba; addr == pop_addr; auto_precharge == 0;}) begin
            `uvm_error("SEQ_RD","random failed")
          end

          finish_item(seq);

          `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr), UVM_LOW)
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
