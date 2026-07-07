// Component    : ddr_wr_sanity_seq_bl2_100_seq
// Test Owner   : Siva Jyothi
//
// Description  :
//   Basic DDR WRITE/READ sanity sequence for Burst Length = 2.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=2, CL=2, Sequential Burst)
//     3. ACTIVATE
//     4. WRITE
//     5. READ
//
//   This sequence performs a simple write followed by a read from the
//   same bank and column to verify basic DDR functionality.
//

class ddr_wr_sanity_seq_bl2_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_sanity_seq_bl2_100_seq)

  DDR_seq_item seq;

  function new(string name ="ddr_wr_sanity_seq_bl2_100_seq");
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
    if(!seq.randomize with {cmd == MRS; cfg_bl==2; cfg_cl == 2; cfg_bt==0;})
      `uvm_error("SEQ_MRS","random failed")
    finish_item(seq);

    `uvm_info("SEQ_MRS",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b",seq.cfg_bl,seq.cfg_cl,seq.cfg_bt),UVM_LOW)


    //-----------------------------------------------------------------------
    // ACTIVATE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    assert(seq.randomize with {cmd == ACTIVATE; ba == 1; addr == 25;});
    finish_item(seq);

    `uvm_info("SEQ",$sformatf("Basic Sanity ACT BL2 BA=%0d ADDR=%0d",seq.ba,seq.addr),UVM_LOW)


    //-----------------------------------------------------------------------
    // WRITE Command
    //-----------------------------------------------------------------------
    start_item(seq);
    assert(seq.randomize with {cmd == WRITE; cfg_bl==2; ba ==1; addr == 8 ; dm==0;auto_precharge==0;});
    finish_item(seq);

    `uvm_info("SEQ",$sformatf("Basic Sanity BL2 BA=%0d ADDR=%0d DATA=%0d",seq.ba,seq.addr,seq.dq), UVM_LOW)


    //-----------------------------------------------------------------------
    // READ Command
    //-----------------------------------------------------------------------
    start_item(seq);
    assert(seq.randomize with {cmd == READ; cfg_bl == 2; ba == 1; addr == 8;auto_precharge==0;});
    finish_item(seq);

  endtask

endclass
