//==============================================================================
// Component Name : ddr_wr_bst_seq_bl8_100_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_wr_bst_seq_bl8_100_test extends DDR_test;

  `uvm_component_utils(ddr_wr_bst_seq_bl8_100_test)

  ddr_wr_bst_seq_bl8_100_seq wr_bst_seq;

  function new(string name = "ddr_wr_bst_seq_bl8_100_test",uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_bst_seq =ddr_wr_bst_seq_bl8_100_seq::type_id::create("wr_bst_seq");

    wr_bst_seq.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


