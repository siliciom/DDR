//==============================================================================
// Component Name : ddr_timing_error_test
// Type           : UVM Test
// Test Owner     : Parikshith
//==============================================================================

class ddr_timing_error_test extends uvm_test;

	// Factory Registration
	`uvm_component_utils(ddr_timing_error_test)

	DDR_env envh;

	ddr_all_cmd_fsm_seq wr_mul_seqh;

	// Constructor
	function new(string name = "ddr_timing_error_test",
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

	envh.agt.monh.set_report_severity_override(UVM_ERROR,UVM_WARNING);
	envh.scrb.set_report_severity_override(UVM_ERROR,UVM_WARNING);
		// Raise objection to keep simulation alive
		phase.raise_objection(this);

		wr_mul_seqh =ddr_all_cmd_fsm_seq::type_id::create("wr_mul_seqh");

		wr_mul_seqh.start(envh.agt.seqh);	
		#150;

		// Drop objection to finish simulation
		phase.drop_objection(this);

	endtask

endclass

