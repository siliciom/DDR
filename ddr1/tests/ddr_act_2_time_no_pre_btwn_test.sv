//==============================================================================
// Component Name : ddr_act_2_time_no_pre_btwn_test
// Type           : UVM Test
// Test Owner     : Saketh
//==============================================================================

class ddr_act_2_time_no_pre_btwn_test extends DDR_test;

	// Factory Registration
	`uvm_component_utils(ddr_act_2_time_no_pre_btwn_test)

	ddr_act_2_time_no_pre_btwn_seq wr_basic_intlv;

	// Constructor
	function new(string name = "ddr_act_2_time_no_pre_btwn_test",
	             uvm_component parent);
		super.new(name, parent);
	endfunction

	// Run Phase
	task run_phase(uvm_phase phase);

		super.run_phase(phase);

		// Raise objection to prevent simulation from ending
		phase.raise_objection(this);

		wr_basic_intlv =ddr_act_2_time_no_pre_btwn_seq::type_id::create("wr_basic_intlv");

		wr_basic_intlv.start(envh.agt.seqh);

		#50;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
