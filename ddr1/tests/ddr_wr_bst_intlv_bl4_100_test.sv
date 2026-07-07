//==============================================================================
// Component Name : ddr_wr_bst_intlv_bl4_100_test
// Type           : UVM Test
// Test Owner     : Parikshith
//==============================================================================


class ddr_wr_bst_intlv_bl4_100_test extends DDR_test;

  `uvm_component_utils(ddr_wr_bst_intlv_bl4_100_test)

  ddr_wr_bst_intlv_bl4_100_seq wr_bst_intlv;

  function new(
    string name = "ddr_wr_bst_intlv_bl4_100_test",
    uvm_component parent
  );
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_bst_intlv =ddr_wr_bst_intlv_bl4_100_seq::type_id::create("wr_bst_intlv");

    wr_bst_intlv.start(envh.agt.seqh);

    #18;

    phase.drop_objection(this);

  endtask

endclass



