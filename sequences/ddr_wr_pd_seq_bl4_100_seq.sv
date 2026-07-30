// ------------------------------------------------------------------------
// Component    : ddr_wr_pd_seq_bl4_100_seq
// Test Owner   : Anitha
//
// Description  :  Powerdown  sequence for Burst Length = 8.
//
// Sequence Flow:
//   1. IDLE
//   2. Mode Register Set (BL=8, CL=2, Interleaving Burst)
//   3. ACTIVATE
//   4. WRITE
//   5. READ
//
// This sequence performs  powerdown operation by making cke low  to verify basic DDR functionality.
// ------------------------------------------------------------------------

class ddr_wr_pd_seq_bl4_100_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_wr_pd_seq_bl4_100_seq)

  int CKE_cycles = 100;

  DDR_seq_item seq;

  function new(string name = "ddr_wr_pd_seq_bl4_100_seq");
    super.new(name);
  endfunction

  task body();

    //-------------------------------------------------
    // 1. PRECHARGE ALL BANKS
    //-------------------------------------------------
    seq = DDR_seq_item::type_id::create("seq");

    start_item(seq);

    if (!seq.randomize() with {
          cmd == PRECHARGE;
          addr[10] == 1;
        })
      `uvm_error("SEQ_PRECHARGE", "Precharge failed")

    finish_item(seq);

    `uvm_info("SEQ_PRECHARGE","Precharge issued",UVM_LOW)

    //-------------------------------------------------
    // 2. NOP with CKE = 1 (Idle before Power-Down)
    //-------------------------------------------------
    start_item(seq);

    seq.cke           = 1;
    seq.cmd           = NOP;
    seq.do_power_down = 0;

    finish_item(seq);

    //-------------------------------------------------
    // 3. Enter Power-Down (CKE = 0)
    //-------------------------------------------------
    seq = DDR_seq_item::type_id::create("seq");

    start_item(seq);

    seq.cke           = 0;
    seq.cmd           = NOP;
    seq.do_power_down = 1;

    finish_item(seq);

    `uvm_info("SEQ_PD","Entering Power-Down",UVM_LOW)

    //-------------------------------------------------
    // 4. Stay in Power-Down for CKE_cycles
    //-------------------------------------------------
    repeat (CKE_cycles) begin

      seq = DDR_seq_item::type_id::create("seq");

      start_item(seq);

      seq.cke           = 0;
      seq.cmd           = NOP;
      seq.do_power_down = 1;

      finish_item(seq);

    end

    //-------------------------------------------------
    // 5. Exit Power-Down (CKE = 1)
    //-------------------------------------------------
    seq = DDR_seq_item::type_id::create("seq");

    start_item(seq);

    seq.cke           = 1;
    seq.cmd           = NOP;
    seq.do_power_down = 1;

    finish_item(seq);

    `uvm_info("SEQ_PD","Exiting Power-Down",UVM_LOW)

  endtask

endclass
