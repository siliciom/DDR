class ddr_wr_basic_seq_bl8_100_seq extends uvm_sequence #(DDR_seq_item);
	`uvm_object_utils(ddr_wr_basic_seq_bl8_100_seq)

	DDR_seq_item seq;
	function new(string name = "ddr_wr_basic_seq_bl8_100_seq");
		super.new(name);
	endfunction

	task body;
		seq =  DDR_seq_item::type_id::create("seq");

		//ACTIVATE
		start_item(seq);
		assert(seq.randomize with {cmd == ACTIVATE; ba==0; addr==20;});
		finish_item(seq);

			`uvm_info("SEQ",$sformatf("Basic Wr ACT BL8 BA=%0d ADDR=%0d",seq.ba,seq.addr),UVM_LOW)

	
		//WRITE
		start_item(seq);
		assert(seq.randomize with {cmd == WRITE; cfg_bl==8; ba==0; addr==11;});
		finish_item(seq);

			`uvm_info("SEQ",$sformatf("Basic Wr WRITE BL8 BA=%0d ADDR=%0d DATA=%0d",seq.ba,seq.addr,seq.dq),UVM_LOW)


		//READ
		start_item(seq);
		assert(seq.randomize with {cmd == READ; ba==0; addr==11;});
		finish_item(seq);

			`uvm_info("SEQ",$sformatf("Basic Wr READ BL8 BA=%0d ADDR=%0d DATA=%0d",seq.ba,seq.addr,seq.dq),UVM_LOW)


	endtask

endclass
