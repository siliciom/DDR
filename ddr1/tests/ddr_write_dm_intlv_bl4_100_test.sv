//==============================================================================
// Component Name : ddr_write_dm_intlv_bl4_100_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_write_dm_intlv_bl4_100_test extends DDR_test;

  `uvm_component_utils(ddr_write_dm_intlv_bl4_100_test)

  ddr_write_dm_intlv_bl4_100_seq wr_dm_intlv;

  function new(
    string name = "ddr_write_dm_intlv_bl4_100_test",
    uvm_component parent
  );
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_dm_intlv =ddr_write_dm_intlv_bl4_100_seq::type_id::create("wr_dm_intlv");

    wr_dm_intlv.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


