//=============================================================================
// Component    : ddr_wr_ovr_wr_data_test
// Test Owner   : Harsh Sharma
//=============================================================================

class ddr_wr_ovr_wr_data_test extends DDR_test;
  `uvm_component_utils(ddr_wr_ovr_wr_data_test)

  //---------------------------------------------------------------------------
  // Sequence Handles
  //---------------------------------------------------------------------------
  ddr_wr_ovr_wr_data_seq wr_ovr_seqh;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "ddr_wr_ovr_wr_data_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Run Phase: Component main execution thread
  //---------------------------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);

    // Prevent phase from ending prematurely
    phase.raise_objection(this);

    // Create the test sequence instance using the factory
    wr_ovr_seqh = ddr_wr_ovr_wr_data_seq::type_id::create("wr_ovr_seqh");

    // Start execution of the sequence on the target agent sequencer
    wr_ovr_seqh.start(envh.agt.seqh);
    
    // Drain delay to allow the overwrite reads and evaluations to settle
    #150;

    // Allow phase to conclude
    phase.drop_objection(this);
  endtask : run_phase

endclass : ddr_wr_ovr_wr_data_test
