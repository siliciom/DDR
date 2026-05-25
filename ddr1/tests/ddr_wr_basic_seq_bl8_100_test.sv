class ddr_wr_basic_seq_bl8_100_test extends DDR_test;

	`uvm_component_utils(ddr_wr_basic_seq_bl8_100_test)

	ddr_wr_basic_seq_bl8_100_seq wr_basic_seqh;

	function new (string name = "ddr_wr_basic_seq_bl8_100_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this);

		wr_basic_seqh = ddr_wr_basic_seq_bl8_100_seq::type_id::create("wr_basic_seqh");

		wr_basic_seqh.start(envh.agt.seqh);
		#18;

		phase.drop_objection(this);
	endtask
endclass
