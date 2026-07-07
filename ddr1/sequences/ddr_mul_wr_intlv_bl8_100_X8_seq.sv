// Component    : ddr_mul_wr_intlv_bl8_100_X8_seq
// Test Owner   : Anitha
//
// Description  : Multiple  WRITE/READ  sequence for Burst Length = 8.
//
//   Sequence Flow:
//     1. IDLE
//     2. Mode Register Set (BL=8, CL=2, interleaving Burst)
//     3. ACTIVATE
//     4. WRITE
//     5. READ
//
//   This sequence performs a multiple write and read  from the
//   different bank and column to verify basic DDR functionality.
// ------------------------------------------------------------------------
			
class ddr_mul_wr_intlv_bl8_100_X8_seq extends uvm_sequence #(DDR_seq_item);

  `uvm_object_utils(ddr_mul_wr_intlv_bl8_100_X8_seq)

  DDR_seq_item seq;

  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;

  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  rand int num;

  constraint counts {
    num inside {[2:5]};
  }

  function new(string name = "ddr_mul_wr_intlv_bl8_100_X8_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");

    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    // IDLE
    start_item(seq);
    if (!seq.randomize() with { cmd == IDLE; })
      `uvm_error("SEQ_IDLE", "random failed")
    finish_item(seq);

    `uvm_info("SEQ_IDLE", "inside idle", UVM_LOW)

    // MRS
    start_item(seq);
    assert(seq.randomize() with {
      cmd    == MRS;
      cfg_bl == 8;
      cfg_cl == 2;
      cfg_bt == 1;
    });
    finish_item(seq);

    `uvm_info("SEQ",$sformatf("MRS_SEQ cfg_bl %0d cfg_cl %0d cfg_bt %0b",seq.cfg_bl, seq.cfg_cl, seq.cfg_bt), UVM_LOW)

    repeat (2) begin

      if (!this.randomize())
        `uvm_error("SEQ_RAND", "Sequence body randomization failed")

      // ACTIVATE
      start_item(seq);
      if (!seq.randomize() with {
            cmd  == ACTIVATE;
            ba   == target_ba;
            addr == target_row;
          })
        `uvm_error("SEQ_ACT", "random failed")
      finish_item(seq);

      `uvm_info("SEQ_ACT",$sformatf("=== BANK ACTIVATED === BA=%0d ROW=%0d",seq.ba, seq.addr), UVM_LOW)

      // WRITE
      `uvm_info("SEQ_WRITE",$sformatf("Starting %0d Randomized Writes", num),UVM_LOW)

      repeat (num) begin

        start_item(seq);

        if (!seq.randomize() with {
              cmd            == WRITE;
              cfg_bl         == 8;
              ba             == target_ba;
              addr[2:0]      == 0;
              auto_precharge == 0;
              dm             == 0;
            })
        begin
          `uvm_error("SEQ_WR", "random failed")
        end

        col_addr.push_back(seq.addr);

        finish_item(seq);

        `uvm_info("SEQ_WR_DATA",$sformatf("WRITE -> BA=%0d COL_ADDR=%0d", seq.ba, seq.addr), UVM_LOW)
      end

      // READ
      `uvm_info("SEQ_READ", $sformatf("Starting %0d Tracking Reads", num), UVM_LOW)

      repeat (num) begin

        if (col_addr.size() > 0) begin

          start_item(seq);

          pop_addr = col_addr.pop_front();

          if (!seq.randomize() with {
                cmd            == READ;
                cfg_bl         == 8;
                ba             == target_ba;
                addr           == pop_addr;
                auto_precharge == 0;
              })
          begin
            `uvm_error("SEQ_RD", "random failed")
          end

          finish_item(seq);

          `uvm_info("SEQ_RD_DATA",$sformatf("READ -> BA=%0d COL_ADDR=%0d",seq.ba, seq.addr), UVM_LOW)
        end

      end

      // PRECHARGE
      start_item(seq);

      if (!seq.randomize() with {
            cmd  == PRECHARGE;
            ba   == target_ba;
            addr == target_row;
          })
        `uvm_error("SEQ_PRECHARGE", "random failed")

      finish_item(seq);

      `uvm_info("SEQ_PRE",$sformatf("=== BANK PRECHARGED === BA=%0d\n",target_ba), UVM_LOW)

    end

  endtask

endclass


