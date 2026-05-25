class DDR_test extends uvm_test;
  `uvm_component_utils(DDR_test)
  
  DDR_env envh;
 // ddr_wr_sanity_seq_bl2_100_seq ddr_seq;
  virtual DDR_interface vif;
  

  //constructor
  function new(string name ="DDR_test",uvm_component parent);
    super.new(name,parent);
  endfunction
  

 //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
 	 //Get interface from top TB
    if(!uvm_config_db #(virtual DDR_interface)::get(this, "", "DDR_interface", vif))
      `uvm_fatal("TEST", "Did not get vif")

    	// Set interface for all components (driver + monitor)
      uvm_config_db #(virtual DDR_interface)::set(this, "*", "DDR_interface", vif);
    
		//Create environment
		envh = DDR_env::type_id::create("envh",this);
    
	endfunction


	//start of simulation
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction


	//run phase
/*   task run_phase (uvm_phase phase);
    	phase.raise_objection(this);
    
		//create sequence
    	ddr_seq=ddr_wr_sanity_seq_bl2_100_seq::type_id::create("ddr_seq");

		//start sequence on sequencer
      ddr_seq.start(envh.agt.seqh);
      #20;
    
      phase.drop_objection(this);
  endtask*/
  
endclass

