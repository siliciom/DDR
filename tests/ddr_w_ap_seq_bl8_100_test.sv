class ddr_w_ap_seq_bl8_100_test extends DDR_test;

	`uvm_component_utils(ddr_w_ap_seq_bl8_100_test)

	ddr_w_ap_seq_bl8_100_seq   wr_ap_seq;

	function new (string name = "ddr_w_ap_seq_bl8_100_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this);

		wr_ap_seq = ddr_w_ap_seq_bl8_100_seq ::type_id::create("wr_ap_seq");

		wr_ap_seq.start(envh.agt.seqh);
		#150;

		phase.drop_objection(this);
	endtask
endclass
