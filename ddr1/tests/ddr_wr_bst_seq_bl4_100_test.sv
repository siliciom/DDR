//==============================================================================
// Component Name : ddr_wr_bst_seq_bl4_100_test
// Type           : UVM Test
// Test Owner     : Siva Jyothi
//==============================================================================

class ddr_wr_bst_seq_bl4_100_test extends DDR_test;

	//----------------------------------------------------------------------------
	// Factory Registration
	//----------------------------------------------------------------------------
	`uvm_component_utils(ddr_wr_bst_seq_bl4_100_test)

	//----------------------------------------------------------------------------
	// Sequence Handle Declaration
	//----------------------------------------------------------------------------
	ddr_wr_bst_seq_bl4_100_seq wr_bst_seq;

	//----------------------------------------------------------------------------
	// Constructor
	//----------------------------------------------------------------------------
	function new (string name = "ddr_wr_bst_seq_bl4_100_test",
	              uvm_component parent);
		super.new(name,parent);
	endfunction

	//----------------------------------------------------------------------------
	// Run Phase
	//----------------------------------------------------------------------------
	task run_phase (uvm_phase phase);

		super.run_phase(phase);

		// Raise objection to prevent simulation from ending
		phase.raise_objection(this);

		// Create the write burst stop sequential sequence
		wr_bst_seq =ddr_wr_bst_seq_bl4_100_seq ::type_id::create("wr_bst_seq");

		// Start the sequence on the agent sequencer
    	wr_bst_seq	.start(envh.agt.seqh);

		// Wait for sequence completion
		#18;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
