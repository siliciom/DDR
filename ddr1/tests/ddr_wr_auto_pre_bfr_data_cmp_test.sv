//==============================================================================
// Component Name : ddr_wr_auto_pre_bfr_data_cmp_test
// Type           : UVM Test
// Test Owner     : Parikshith
//==============================================================================


class ddr_wr_auto_pre_bfr_data_cmp_test extends DDR_test;

  `uvm_component_utils(ddr_wr_auto_pre_bfr_data_cmp_test)

  ddr_wr_auto_pre_bfr_data_cmp_seq ddr_wr_seqh;

  function new(string name = "ddr_wr_auto_pre_bfr_data_cmp_test",  uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

     envh.scrb.set_report_severity_id_override(UVM_ERROR,"SCB_BANK_CLOSED",UVM_WARNING);
    phase.raise_objection(this);

    ddr_wr_seqh = ddr_wr_auto_pre_bfr_data_cmp_seq::type_id::create("ddr_wr_seqh");

    ddr_wr_seqh.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


