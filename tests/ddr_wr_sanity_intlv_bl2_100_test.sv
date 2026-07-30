//=============================================================================
// Component    : ddr_wr_sanity_intlv_bl2_100_test
// Test Owner   : Parikshith S D
//=============================================================================

class ddr_wr_sanity_intlv_bl2_100_test extends DDR_test;
  `uvm_component_utils(ddr_wr_sanity_intlv_bl2_100_test)

  //---------------------------------------------------------------------------
  // Sequence Handles
  //---------------------------------------------------------------------------
  ddr_wr_sanity_intlv_bl2_100_seq wr_sanity_intlv;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "ddr_wr_sanity_intlv_bl2_100_test", uvm_component parent = null);
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
    wr_sanity_intlv = ddr_wr_sanity_intlv_bl2_100_seq::type_id::create("wr_sanity_intlv");

    // Start execution of the sequence on the target agent sequencer
    wr_sanity_intlv.start(envh.agt.seqh);
    
    // Drain delay to allow the short burst operations to finish
    #150;

    // Allow phase to conclude
    phase.drop_objection(this);
  endtask : run_phase

endclass : ddr_wr_sanity_intlv_bl2_100_test
