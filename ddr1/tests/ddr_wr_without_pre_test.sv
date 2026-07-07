//=============================================================================
// Component    : ddr_wr_without_pre_test
// Test Owner   : Harsh Sharma
//=============================================================================

class ddr_wr_without_pre_test extends DDR_test;
  `uvm_component_utils(ddr_wr_without_pre_test)

  //---------------------------------------------------------------------------
  // Sequence Handles
  //---------------------------------------------------------------------------
  ddr_wr_without_pre_seq wr_without_pre_seqh;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "ddr_wr_without_pre_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Run Phase: Component main execution thread
  //---------------------------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    envh.scrb.set_report_severity_id_override(UVM_ERROR,"SCB_BANK_CLOSED",UVM_WARNING);
    // Prevent phase from ending prematurely
    phase.raise_objection(this);

    // Create the test sequence instance using the factory
    wr_without_pre_seqh = ddr_wr_without_pre_seq::type_id::create("wr_without_pre_seqh");

    // Start execution of the sequence on the target agent sequencer
    wr_without_pre_seqh.start(envh.agt.seqh);
    
    // Drain delay to allow the error injection transaction results to propagate
    #18;

    // Allow phase to conclude
    phase.drop_objection(this);
  endtask : run_phase

endclass : ddr_wr_without_pre_test
