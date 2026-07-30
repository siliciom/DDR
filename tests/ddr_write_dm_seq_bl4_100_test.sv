class ddr_write_dm_seq_bl4_100_test extends DDR_test;

	`uvm_component_utils(ddr_write_dm_seq_bl4_100_test)

	ddr_write_dm_seq_bl4_100_seq w_dm_seqh;

	function new (string name = "ddr_write_dm_seq_bl4_100_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);

		phase.raise_objection(this);

		w_dm_seqh = ddr_write_dm_seq_bl4_100_seq::type_id::create("wr_ar_seqh");

		w_dm_seqh.start(envh.agt.seqh);
		#18;

		phase.drop_objection(this);
	endtask
endclass



