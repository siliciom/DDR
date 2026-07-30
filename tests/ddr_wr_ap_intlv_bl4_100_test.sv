//==============================================================================
// Component Name : ddr_wr_ap_intlv_bl4_100_test
// Type           : UVM Test
// Test Owner     : parikshith

//==============================================================================

class ddr_wr_ap_intlv_bl4_100_test extends DDR_test;

	`uvm_component_utils(ddr_wr_ap_intlv_bl4_100_test)

	ddr_wr_ap_intlv_bl4_100_seq wr_ap_intlv_bl4;
           // constructor
	function new (string name = "ddr_wr_ap_intlv_bl4_100_test",
	              uvm_component parent);
		super.new(name,parent);
	endfunction
           // Run phase
	task run_phase (uvm_phase phase);

		super.run_phase(phase);
            // Prevent simulation from ending early

		phase.raise_objection(this);
 		
		wr_ap_intlv_bl4 =ddr_wr_ap_intlv_bl4_100_seq::type_id::create("wr_ap_intlv_bl4");

		wr_ap_intlv_bl4.start(envh.agt.seqh);

		#150;
           // Allow simulation to end
		phase.drop_objection(this);

	endtask

endclass
