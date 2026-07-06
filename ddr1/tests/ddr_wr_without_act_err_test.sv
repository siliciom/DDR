//==============================================================================
// Component Name : ddr_wr_without_act_err_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================
class ddr_wr_without_act_err_test extends DDR_test;

  `uvm_component_utils(ddr_wr_without_act_err_test)

  ddr_wr_without_act_err_seq wr_without_act;

  function new(string name = "ddr_wr_without_act_err_test",uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    
	 envh.scrb.set_report_severity_id_override(UVM_ERROR,"SCB_BANK_CLOSED",UVM_WARNING);

    phase.raise_objection(this);

    wr_without_act = ddr_wr_without_act_err_seq::type_id::create("wr_without_act");

    wr_without_act.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


