class ddr_wr_sanity_seq_bl2_100_test extends DDR_test;

	`uvm_component_utils(ddr_wr_sanity_seq_bl2_100_test)

	ddr_wr_sanity_seq_bl2_100_seq wr_sanity_seqh;

	function new (string name = "ddr_wr_sanity_seq_bl2_100_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this);

		wr_sanity_seqh = ddr_wr_sanity_seq_bl2_100_seq::type_id::create("wr_sanity_seqh");

		wr_sanity_seqh.start(envh.agt.seqh);
		#150;

		phase.drop_objection(this);
	endtask
endclass
