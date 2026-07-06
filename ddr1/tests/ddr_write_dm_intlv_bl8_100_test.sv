//=============================================================================
// Component    : ddr_write_dm_intlv_bl8_100_test
// Test Owner   : Harsh Sharma
//=============================================================================

class ddr_write_dm_intlv_bl8_100_test extends DDR_test;
  `uvm_component_utils(ddr_write_dm_intlv_bl8_100_test)

  //---------------------------------------------------------------------------
  // Sequence Handles
  //---------------------------------------------------------------------------
  ddr_write_dm_intlv_bl8_100_seq w_dm_seqh;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "ddr_write_dm_intlv_bl8_100_test", uvm_component parent = null);
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
    w_dm_seqh = ddr_write_dm_intlv_bl8_100_seq::type_id::create("wr_ar_seqh");

    // Start execution of the sequence on the target agent sequencer
    w_dm_seqh.start(envh.agt.seqh);
    
    // Drain delay to allow the data-masked operations to complete through the DUT
    #150;

    // Allow phase to conclude
    phase.drop_objection(this);
  endtask : run_phase

endclass : ddr_write_dm_intlv_bl8_100_test
