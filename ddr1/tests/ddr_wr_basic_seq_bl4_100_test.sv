//==============================================================================
// Component Name : ddr_wr_basic_seq_bl4_100_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_wr_basic_seq_bl4_100_test extends uvm_test;

  `uvm_component_utils(ddr_wr_basic_seq_bl4_100_test)

  DDR_env envh;
  ddr_wr_basic_seq_bl4_100_seq wr_basic_seqh;

  function new(string name = "ddr_wr_basic_seq_bl4_100_test", uvm_component parent );
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    envh = DDR_env::type_id::create("envh", this);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_basic_seqh = ddr_wr_basic_seq_bl4_100_seq::type_id::create("wr_basic_seqh");

    wr_basic_seqh.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass
