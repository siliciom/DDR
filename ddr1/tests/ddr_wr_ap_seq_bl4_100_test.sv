//==============================================================================
// Component Name : ddr_wr_ap_seq_bl4_100_test
// Type           : UVM Test
// Test Owner     : Siva Jyothi
//==============================================================================

class ddr_wr_ap_seq_bl4_100_test extends DDR_test;

	//----------------------------------------------------------------------------
	// Factory Registration
	//----------------------------------------------------------------------------
	`uvm_component_utils(ddr_wr_ap_seq_bl4_100_test)

	//----------------------------------------------------------------------------
	// Sequence Handle Declaration
	//----------------------------------------------------------------------------
	ddr_wr_ap_seq_bl4_100_seq   wr_ap_seqh;

	//----------------------------------------------------------------------------
	// Constructor
	//----------------------------------------------------------------------------
	function new (string name = "ddr_wr_ap_seq_bl4_100_test",
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

		// Create the write auto-precharge sequential sequence
		wr_ap_seqh =  ddr_wr_ap_seq_bl4_100_seq::type_id::create("wr_ap_seqh");

		// Start the sequence on the agent sequencer
		wr_ap_seqh.start(envh.agt.seqh);

		// Wait for sequence completion
		#150;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
