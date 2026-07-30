//==============================================================================
// Component Name : ddr_act4_wr_op_data_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_act4_wr_op_data_test extends DDR_test;

  `uvm_component_utils(ddr_act4_wr_op_data_test)

  ddr_act4_wr_op_data_seq wr_act4;

  function new(string name = "ddr_act4_wr_op_data_test",uvm_component parent );
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_act4 =ddr_act4_wr_op_data_seq::type_id::create("wr_act4");

    wr_act4.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


