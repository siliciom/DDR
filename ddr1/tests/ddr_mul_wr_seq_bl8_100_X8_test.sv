//==============================================================================
// Component Name : ddr_mul_wr_seq_bl8_100_X8_test
// Type           : UVM Test
// Test Owner     : Parikshith
//==============================================================================

class ddr_mul_wr_seq_bl8_100_X8_test extends DDR_test;

	//----------------------------------------------------------------------------
	// Factory Registration
	//----------------------------------------------------------------------------
	`uvm_component_utils(ddr_mul_wr_seq_bl8_100_X8_test)

	//----------------------------------------------------------------------------
	// Sequence Handle Declaration
	//----------------------------------------------------------------------------
	ddr_mul_wr_seq_bl8_100_X8_seq wr_mul_seqh;

	//----------------------------------------------------------------------------
	// Constructor
	//----------------------------------------------------------------------------
	function new (string name = "ddr_mul_wr_seq_bl8_100_X8_test",
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

		// Create the multiple write sequential sequence
		wr_mul_seqh = ddr_mul_wr_seq_bl8_100_X8_seq::type_id::create("wr_mul_seqh");

		// Start the sequence on the agent sequencer
		wr_mul_seqh.start(envh.agt.seqh);

		// Wait for sequence completion
		#150;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
