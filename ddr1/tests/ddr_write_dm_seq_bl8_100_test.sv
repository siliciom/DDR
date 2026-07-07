//==============================================================================
// Component Name : ddr_write_dm_seq_bl8_100_test
// Type           : UVM Test
// Test Owner     : Saketh
//==============================================================================

class ddr_write_dm_seq_bl8_100_test extends DDR_test;

	// Factory Registration
	`uvm_component_utils(ddr_write_dm_seq_bl8_100_test)

	ddr_write_dm_seq_bl8_100_seq w_dm_seqh;

	// Constructor
	function new(string name = "ddr_write_dm_seq_bl8_100_test",
	             uvm_component parent);
		super.new(name, parent);
	endfunction

	// Run Phase
	task run_phase(uvm_phase phase);

		super.run_phase(phase);

		// Raise objection to prevent simulation from ending
		phase.raise_objection(this);

		w_dm_seqh =ddr_write_dm_seq_bl8_100_seq::type_id::create("w_dm_seqh");

		w_dm_seqh.start(envh.agt.seqh);

		#150;

		// Drop objection to allow simulation to finish
		phase.drop_objection(this);

	endtask

endclass
