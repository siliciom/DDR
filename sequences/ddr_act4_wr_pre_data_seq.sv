// Component    : ddr_act4_wr_pre_data_seq
// Test Owner   : Siva Jyothi
//
// Description  :
//   DDR sequence to verify ACTIVATE, WRITE, READ and PRECHARGE operations
//   across all four banks using BL4 Interleaved Burst mode.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=4, CL=2, Interleaved Burst)
//     3. Randomize unique bank activation order
//     4. ACTIVATE all four banks
//     5. WRITE to all activated banks
//     6. PRECHARGE Bank 1
//     7. READ from all banks
//     8. PRECHARGE ALL banks
//     9. WRITE to all banks again
//
//   This sequence verifies bank activation order, single-bank precharge,
//   precharge-all behavior and data access across all four banks.
//

class ddr_act4_wr_pre_data_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_act4_wr_pre_data_seq)

  DDR_seq_item seq;

  rand bit [1:0]  bank_order[4];
  rand bit [13:0] target_row;

  // Randomize all four banks in unique order
  constraint bank_order_c {
    unique {bank_order};
  }

  // Stores WRITE column address for each bank
  bit [9:0] wr_col[4];


  function new(string name="ddr_act4_wr_pre_data_seq");
    super.new(name);
  endfunction


  task body();

    seq = DDR_seq_item::type_id::create("seq");

    //-----------------------------------------------------------------------
    // IDLE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize() with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE","Randomization Failed")
    finish_item(seq);


    //-----------------------------------------------------------------------
    // Mode Register Set (MRS)
    // BL = 4
    // CL = 2
    // Interleaved Burst
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize() with {cmd == MRS; cfg_bl == 4; cfg_cl == 2; cfg_bt == 1;})
      `uvm_error("SEQ_MRS","Randomization Failed")
    finish_item(seq);


    //-----------------------------------------------------------------------
    // Randomize Target Row and Unique Bank Order
    //-----------------------------------------------------------------------
    if(!this.randomize())
      `uvm_fatal("SEQ","Randomization Failed")

    `uvm_info("BANK_ORDER",$sformatf("ORDER=%0d %0d %0d %0d",bank_order[0],bank_order[1],bank_order[2],bank_order[3]),UVM_LOW)


    //-----------------------------------------------------------------------
    // ACTIVATE All Banks
    //-----------------------------------------------------------------------
    foreach(bank_order[i]) begin

      start_item(seq);
      if(!seq.randomize() with {
        cmd  == ACTIVATE;
        ba   == bank_order[i];
        addr == target_row;
      })
        `uvm_error("SEQ_ACT","Randomization Failed")

      finish_item(seq);

      `uvm_info("SEQ_ACT",$sformatf("ACT BA=%0d ROW=%0d",seq.ba,seq.addr),UVM_LOW)
    end


    //-----------------------------------------------------------------------
    // WRITE to All Banks
    //-----------------------------------------------------------------------
    foreach(bank_order[i]) begin

      start_item(seq);
      if(!seq.randomize() with {
        cmd            == WRITE;
        ba             == bank_order[i];
        cfg_bl         == 4;
        addr[2:0]      == 0;
        auto_precharge == 0;
        dm             == 0;
      })
        `uvm_error("SEQ_WR","Randomization Failed")

      // Store WRITE column address for corresponding bank
      wr_col[bank_order[i]] = seq.addr;

      finish_item(seq);

      `uvm_info("SEQ_WR",$sformatf("WRITE BA=%0d COL=%0d",seq.ba,seq.addr),UVM_LOW)
    end


    //-----------------------------------------------------------------------
    // PRECHARGE Single Bank (Bank 1)
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize() with {
      cmd            == PRECHARGE;
      ba             == 1;
      addr           == target_row;
      precharge_all  == 0;
    })
      `uvm_error("SEQ_PRE","Randomization Failed")

    finish_item(seq);

    `uvm_info("SEQ_PRE","PRECHARGE SINGLE BANK BA=1",UVM_LOW)


    //-----------------------------------------------------------------------
    // READ from All Banks
    //-----------------------------------------------------------------------
    foreach(bank_order[i]) begin

      start_item(seq);
      if(!seq.randomize() with {
        cmd            == READ;
        ba             == bank_order[i];
        cfg_bl         == 4;
        addr           == wr_col[bank_order[i]];
        auto_precharge == 0;
      })
        `uvm_error("SEQ_RD","Randomization Failed")

      finish_item(seq);

      `uvm_info("SEQ_RD",$sformatf("READ BA=%0d COL=%0d",seq.ba,seq.addr),UVM_LOW)
    end


    //-----------------------------------------------------------------------
    // PRECHARGE ALL Banks
    //-----------------------------------------------------------------------
    start_item(seq);
    if(!seq.randomize() with {
      cmd == PRECHARGE;
      precharge_all == 1;
    })
      `uvm_error("SEQ_PREALL","Randomization Failed")

    finish_item(seq);

    `uvm_info("SEQ_PREALL","PRECHARGE ALL BANKS",UVM_LOW)


    //-----------------------------------------------------------------------
    // WRITE to All Banks After PRECHARGE ALL
    //-----------------------------------------------------------------------
    foreach(bank_order[i]) begin

      start_item(seq);
      if(!seq.randomize() with {
        cmd            == WRITE;
        ba             == bank_order[i];
        cfg_bl         == 4;
        addr[2:0]      == 0;
        auto_precharge == 0;
        dm             == 0;
      })
        `uvm_error("SEQ_WR","Randomization Failed")

      // Store latest WRITE column address
      wr_col[bank_order[i]] = seq.addr;

      finish_item(seq);

      `uvm_info("SEQ_WR",$sformatf("WRITE BA=%0d COL=%0d",seq.ba,seq.addr),UVM_LOW)
    end

  endtask

endclass
