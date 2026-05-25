class ddr_wr_sanity_seq_bl2_100_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_wr_sanity_seq_bl2_100_seq)

   DDR_seq_item seq;

  function new(string name ="ddr_wr_sanity_seq_bl2_100_seq");
    super.new(name);
  endfunction

  task body();
		seq = DDR_seq_item::type_id::create("seq");
			`uvm_info("SEQ", "Generating transaction", UVM_LOW)
	
			start_item(seq);
		assert(seq.randomize with {cmd == MRS; cfg_bl==4;});
		finish_item(seq);
			`uvm_info("SEQ",$sformatf("MRS_SEQ cfg_bl %0d",seq.cfg_bl),UVM_LOW)
	

		//ACTIVATE
		start_item(seq);
		assert(seq.randomize with {cmd == ACTIVATE; ba==0; addr==20;});
		finish_item(seq);
			`uvm_info("SEQ",$sformatf("Basic Sanity ACT BL2 BA=%0d ADDR=%0d",seq.ba,seq.addr),UVM_LOW)
	
		//WRITE
		start_item(seq);
		assert(seq.randomize with {cmd == WRITE; cfg_bl==4; ba==0; addr==11;});
		finish_item(seq);
			`uvm_info("SEQ",$sformatf("Basic Sanity BL2 BA=%0d ADDR=%0d DATA=%0d",seq.ba,seq.addr,seq.dq),UVM_LOW)

/*		//READ
		start_item(seq);
		assert(seq.randomize with {cmd == READ; ba==0; addr==11;});
		finish_item(seq);

			`uvm_info("SEQ",$sformatf("Basic Wr READ BL8 BA=%0d ADDR=%0d DATA=%0d",seq.ba,seq.addr,seq.dq),UVM_LOW)*/

	endtask

endclass



