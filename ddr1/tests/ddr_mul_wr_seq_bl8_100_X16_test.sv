//=============================================================================
// Component    : ddr_mul_wr_seq_bl8_100_X16_test
// Test Owner   : Parikshith S D
//=============================================================================

class ddr_mul_wr_seq_bl8_100_X16_test extends DDR_test;
  `uvm_component_utils(ddr_mul_wr_seq_bl8_100_X16_test)

  //---------------------------------------------------------------------------
  // Sequence Handles
  //---------------------------------------------------------------------------
  ddr_mul_wr_seq_bl8_100_X16_seq wr_mul_seqh_x16;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "ddr_mul_wr_seq_bl8_100_X16_test", uvm_component parent = null);
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
    wr_mul_seqh_x16 = ddr_mul_wr_seq_bl8_100_X16_seq::type_id::create("wr_mul_seqh_x16");

    // Start execution of the sequence on the target agent sequencer
    wr_mul_seqh_x16.start(envh.agt.seqh);
    
    // Drain delay to allow long burst pipeline data to clear completely
    #150;

    // Allow phase to conclude
    phase.drop_objection(this);
  endtask : run_phase

endclass : ddr_mul_wr_seq_bl8_100_X16_test
