//==============================================================================
// Component Name : ddr_all_cmd_fsm_test
// Type           : UVM Test
// Test Owner     : Saketh
//==============================================================================

class ddr_all_cmd_fsm_test extends uvm_test;

	// Factory Registration
	`uvm_component_utils(ddr_all_cmd_fsm_test)

	DDR_env envh;

	ddr_all_cmd_fsm_seq wr_mul_seqh;

	// Constructor
	function new(string name = "ddr_all_cmd_fsm_test",
	             uvm_component parent);
		super.new(name, parent);
	endfunction

	// Build Phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		envh = DDR_env::type_id::create("envh", this);
	endfunction

	// Run Phase
	task run_phase(uvm_phase phase);

		super.run_phase(phase);

		// Raise objection to keep simulation alive
		phase.raise_objection(this);

		wr_mul_seqh =ddr_all_cmd_fsm_seq::type_id::create("wr_mul_seqh");

		wr_mul_seqh.start(envh.agt.seqh);	
		#150;

		// Drop objection to finish simulation
		phase.drop_objection(this);

	endtask

endclass
