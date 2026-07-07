//==============================================================================
// Component Name : ddr_wr_basic_intlv_bl4_100_test
// Type           : UVM Test
// Test Owner     : Saketh
//==============================================================================

class ddr_wr_basic_intlv_bl4_100_test extends DDR_test;

	// Factory Registration
	`uvm_component_utils(ddr_wr_basic_intlv_bl4_100_test)

	ddr_wr_basic_intlv_bl4_100_seq wr_basic_intlv;

	// Constructor
	function new(string name = "ddr_wr_basic_intlv_bl4_100_test",
	             uvm_component parent);
		super.new(name, parent);
	endfunction

	// Run Phase
	task run_phase(uvm_phase phase);

		super.run_phase(phase);

		// Raise objection to prevent simulation from ending
		phase.raise_objection(this);

		wr_basic_intlv =
			ddr_wr_basic_intlv_bl4_100_seq::type_id::create("wr_basic_intlv");

		wr_basic_intlv.start(envh.agt.seqh);

		#50;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
