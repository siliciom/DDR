//==============================================================================
// Component Name : ddr_mul_wr_intlv_bl4_100_X16_test
// Type           : UVM Test
// Test Owner     : Siva Jyothi
//==============================================================================

class ddr_mul_wr_intlv_bl4_100_X16_test extends DDR_test;

	//----------------------------------------------------------------------------
	// Factory Registration
	//----------------------------------------------------------------------------
	`uvm_component_utils(ddr_mul_wr_intlv_bl4_100_X16_test)

	//----------------------------------------------------------------------------
	// Sequence Handle Declaration
	//----------------------------------------------------------------------------
	ddr_mul_wr_intlv_bl4_100_X16_seq   wr_mul_intlv;

	//----------------------------------------------------------------------------
	// Constructor
	//----------------------------------------------------------------------------
	function new (string name = "ddr_mul_wr_intlv_bl4_100_X16_test",
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

		// Create the multiple write interleaved sequence
		wr_mul_intlv = ddr_mul_wr_intlv_bl4_100_X16_seq ::type_id::create("wr_mul_intlv");

		// Start the sequence on the agent sequencer
		wr_mul_intlv.start(envh.agt.seqh);

		// Wait for sequence completion
		#150;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
