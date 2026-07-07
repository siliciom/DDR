//==============================================================================
// Component Name : ddr_act4_wr_pre_data_test
// Type           : UVM Test
// Test Owner     : Siva Jyothi
//==============================================================================

class ddr_act4_wr_pre_data_test extends DDR_test;

	//----------------------------------------------------------------------------
	// Factory Registration
	//----------------------------------------------------------------------------
	`uvm_component_utils(ddr_act4_wr_pre_data_test)

	//----------------------------------------------------------------------------
	// Sequence Handle Declaration
	//----------------------------------------------------------------------------
	ddr_act4_wr_pre_data_seq wr_basic_intlv;

	//----------------------------------------------------------------------------
	// Constructor
	//----------------------------------------------------------------------------
	function new (string name = "ddr_act4_wr_pre_data_test",
	              uvm_component parent);
		super.new(name,parent);
	endfunction

	//----------------------------------------------------------------------------
	// Run Phase
	//----------------------------------------------------------------------------
	task run_phase (uvm_phase phase);

		super.run_phase(phase);
		envh.scrb.set_report_severity_id_override(UVM_ERROR,"SCB_BANK_CLOSED",UVM_WARNING);
		// Raise objection to prevent simulation from ending
		phase.raise_objection(this);

		// Create the ACT4 write precharge data sequence
		wr_basic_intlv = ddr_act4_wr_pre_data_seq::type_id::create("wr_basic_intlv");

		// Start the sequence on the agent sequencer
		wr_basic_intlv.start(envh.agt.seqh);

		// Wait for sequence completion
		#50;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
