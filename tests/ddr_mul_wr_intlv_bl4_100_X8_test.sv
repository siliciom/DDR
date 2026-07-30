class ddr_mul_wr_intlv_bl4_100_X8_test extends DDR_test;

	`uvm_component_utils(ddr_mul_wr_intlv_bl4_100_X8_test)

	ddr_mul_wr_intlv_bl4_100_X8_seq   wr_mul_intlv;

	function new (string name = "ddr_mul_wr_intlv_bl4_100_X8_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this);

		wr_mul_intlv = ddr_mul_wr_intlv_bl4_100_X8_seq ::type_id::create("wr_mul_intlv");

		wr_mul_intlv.start(envh.agt.seqh);
		#150;

		phase.drop_objection(this);
	endtask
endclass
