// Component    : ddr_wr_basic_intlv_bl8_100_seq
// Test Owner   : Siva Jyothi
//
// Description  :
//   Basic DDR WRITE/READ sanity sequence for Interleaved Burst Length = 8.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=8, CL=2, Interleaved Burst)
//     3. Randomize Bank and Row
//     4. ACTIVATE
//     5. WRITE
//     6. READ
//
//   This sequence performs a basic interleaved burst write followed by a
//   read from the same bank and column address to verify BL8 interleaved
//   burst functionality.
//

class ddr_wr_basic_intlv_bl8_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_basic_intlv_bl8_100_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;


  function new(string name ="ddr_wr_basic_intlv_bl8_100_seq");
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
    if(!seq.randomize with {cmd == MRS; cfg_bl==8; cfg_cl == 2; cfg_bt==1;})
      `uvm_error("SEQ_MRS","random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b",seq.cfg_bl,seq.cfg_cl,seq.cfg_bt),UVM_LOW)


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
    // WRITE Command
    //-----------------------------------------------------------------------
    `uvm_info("SEQ_WRITE",$sformatf("Starting Randomized Writes"),UVM_LOW)

    start_item(seq);
    if(!seq.randomize with {cmd == WRITE; cfg_bl == 8; ba == target_ba;addr[2:0]==0;auto_precharge==0;dm == 0;}) begin
      `uvm_error("SEQ_WR","random failed")
    end

    // Store write column address for readback
    col_addr.push_back(seq.addr);

    finish_item(seq);

    `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr),UVM_LOW)


    //-----------------------------------------------------------------------
    // READ Command
    //-----------------------------------------------------------------------
    `uvm_info("SEQ_READ", $sformatf("Starting Tracking Reads"), UVM_LOW)

    if (col_addr.size() > 0) begin

      start_item(seq);

      // Retrieve stored write column address
      pop_addr = col_addr.pop_front();

      if(!seq.randomize with {cmd == READ; cfg_bl == 8; ba == target_ba; auto_precharge==0;addr == pop_addr;}) begin
        `uvm_error("SEQ_RD","random failed")
      end

      finish_item(seq);

      `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr),UVM_LOW)
    end

  endtask

endclass
