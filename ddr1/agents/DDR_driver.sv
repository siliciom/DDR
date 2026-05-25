class DDR_driver extends uvm_driver #(DDR_seq_item); 
	`uvm_component_utils(DDR_driver)

	virtual DDR_interface vif;
	DDR_seq_item seq;
  	int cfg_cl =2;	

		

	//constructor
  function new(string name = "DDR_driver",uvm_component parent);
    super.new(name,parent);
  endfunction

	//build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	  
	//get interface
    if(!uvm_config_db #(virtual DDR_interface)::get(this,"","DDR_interface",vif))begin
      `uvm_fatal("DRV","NO INTERFACE")
    end
 
  endfunction
 
 
	//run phase
	task run_phase(uvm_phase phase);
   	 //idle
	//	seq = DDR_seq_item::type_id::create("seq");
 
		vif.cs  <=1;
      vif.ras <=0;
      vif.cas <=0;
      vif.we  <=0;
      vif.ba  <=0;
      vif.addr<=0;
      vif.dq  <=0;
      vif.dqs <=0;
	  	vif.dm  <=0;
	  	vif.cke <=0;
		
	//	ddr_init();
		seq_item_port.get_next_item(seq);
					ddr_init();
      		drive_tx(seq);
      		seq_item_port.item_done(); 
 		 forever begin
      		seq_item_port.get_next_item(seq);
			//	seq.cfg_bl;
				//	ddr_init();
      		drive_tx(seq);
      		seq_item_port.item_done(); 
    		end
 
  endtask


  //task initilaization
  task ddr_init();
 
		//cke
		vif.cke <=0;
		@(posedge vif.ck_t); 
    	vif.cke <= 1;
 
		//NOP
    	vif.cs  <= 0; vif.ras <= 1; vif.cas <= 1; vif.we  <= 1;

    	@(posedge vif.ck_t);

 		//Precharge all
    	vif.cs  <= 0; vif.ras <= 0; vif.cas <= 1; vif.we  <= 0;
    	vif.addr[10] <= 1;
 
		#`TRP

    	vif.addr[10] <= 0;
 
   	//emrs enable  
    	vif.cs  <= 0; vif.ras <= 0; vif.cas <= 0; vif.we  <= 0;
    	vif.ba   <= 2'b01;

		//Enable DLL
    	vif.addr[0] <= 0;
 
		#`TMRD
 
   	// mrs--dll reset
    	vif.cs  <= 0; vif.ras <= 0; vif.cas <= 0; vif.we  <= 0;
    	vif.ba  <= 2'b00;
    	vif.addr[8] <= 1;
 
		#`TMRD

		//200 CLock cycle for DLL reset (`TDLL=200)
		repeat(`TDLL) begin
		  @(posedge vif.ck_t);
		  //NOP
		  vif.cs  <= 0; vif.ras <= 1; vif.cas <= 1; vif.we  <= 1;
 
    	end

		//Precharge All
      vif.cs  <= 0; vif.ras <= 0;vif.cas <= 1;vif.we  <= 0;
      vif.addr[10] <= 1;
 
	 	#`TRP;
 		
		//2 Auto refreshes
		// First Auto refresh
      vif.cs  <= 0; vif.ras <= 0; vif.cas <= 0; vif.we  <= 1;  
		#`TRFC;
 
		// Second Auto refresh
      vif.cs  <= 0; vif.ras <= 0; vif.cas <= 0; vif.we  <= 1; 
		#`TRFC;
 
		//MRS task
	//	if(seq.cmd== MRS)
	//	begin
	//			  $display("Inside mrs");
		mrs(0);
	//	end
 
	endtask
 

	//Task MRS
	task mrs(bit dll_reset);
		bit[13:0]mode_reg;
		bit[2:0]bl_bits;
		bit[2:0]cl_bits;
	//	bit[3:0] hh;

	//	hh = seq.cfg_bl;
		`uvm_info("DRVVV",$sformatf("%0d",seq.cfg_bl),UVM_LOW);
			//Burst Length
		case(seq.cfg_bl)
	 		2:bl_bits = 3'b001;
	 		4:bl_bits = 3'b010;
	 		8:bl_bits = 3'b011;
	 	default: begin
	 		bl_bits = 3'b000;
	 		`uvm_warning("mrs","invalid BL")
	 	end
		endcase
 
		//CAS Latency
    	case(cfg_cl)
			2:cl_bits = 3'b010;
	 		3:cl_bits = 3'b011;
	 		default: begin
	 		cl_bits = 3'b010;
	 		`uvm_warning("mrs","invalid CL,using 2")
	 		end
		endcase
 
   	mode_reg = 14'b0;
   	mode_reg[2:0] = bl_bits;
   	mode_reg[3] = seq.cfg_bt;
   	mode_reg[6:4] = cl_bits;
   	mode_reg[8] = dll_reset;
 
  		 	@(posedge vif.ck_t);
			//MRS
    		vif.cs  <= 0; vif.ras <= 0; vif.cas <= 0; vif.we  <= 0;
	 		vif.ba   <= 2'b00;
    		vif.addr <= mode_reg;
 
			#`TMRD;
 
			`uvm_info("MRS",$sformatf("BL=%0d CL=%0d BT=%0d DLL=%0d",seq.cfg_bl,cfg_cl,seq.cfg_bt,dll_reset),UVM_LOW)
	endtask
 
	//NOP
	task nop();
  		vif.cs <=0; vif.ras <=1;  vif.cas <=1; vif.we <=1;
	endtask

	//Activate
	task activate(bit[1:0]ba,bit[13:0]addr);
    	vif.cs  <= 0; vif.ras <= 0; vif.cas <= 1; vif.we  <= 1;
    	vif.ba  <= ba;
   	vif.addr <= addr;
	endtask
 
	//Write command
	task write_cmnd(bit[1:0]ba,bit[9:0]addr);
    	vif.cs  <= 0; vif.ras <= 1; vif.cas <= 0; vif.we  <= 0;
    	vif.ba  <= ba;
    	vif.addr<= addr;
   endtask

	//Read command
	task read_cmnd(bit[1:0]ba,bit[9:0]addr); 
    	vif.cs  <= 0; vif.ras <= 1; vif.cas <= 0; vif.we <= 1;
    	vif.ba  <= ba;
    	vif.addr <= addr;
	endtask

	//Precharge
	task precharge(bit[1:0]ba,bit [9:0] addr);
    	vif.cs  <= 0; vif.ras <= 0; vif.cas <= 1; vif.we <= 0;
    	vif.ba  <= ba;
    	vif.addr<= addr;
	endtask

	//Drive Task
	task drive_tx(DDR_seq_item seq);
  		bit [9:0] burst_addr;
  		seq.auto_precharge = seq.addr[10];
  		burst_addr = seq.addr[9:0];

	//NOP
	nop();
  `uvm_info("DDR_DRV_NOP","Inside NOP command", UVM_LOW);

	// Activate
	if(seq.cmd == ACTIVATE) begin
  		activate(seq.ba, seq.addr);
  		`uvm_info("DDR_DRV_ACTV",$sformatf("BA = %d, ADDR = %d",seq.ba, seq.addr), UVM_LOW);
 	end
  		#`TRCD;

	//Write 
  if(seq.cmd == WRITE) begin
    write_cmnd(seq.ba, burst_addr);
    #`TDQSS;

    for(int i=0; i<seq.cfg_bl; i++) begin
				`uvm_info("DRVVV_WRITE",$sformatf("%0d",seq.cfg_bl),UVM_LOW);

		fork
			begin
			//	#`TCK4;	
				vif.dq <= seq.dq_burst[i];
      		vif.dm <= seq.dm;
      		burst_addr = seq.addr[9:0] + i;
				vif.addr <= burst_addr;
		 	end
 
			begin
				#`TCK4;
				vif.dqs <= ~vif.dqs;
			end

      `uvm_info("DDR_DRIVER",$sformatf("ADDR = %0d DATA[%0d] = %0d",burst_addr,i,seq.dq_burst[i]),UVM_LOW)
		join
		#`TCK4;
    end
 

	 /*//Precharge
	 if(seq.cmd==WR_PRECHARGE) begin
    	if(seq.auto_precharge == 0) begin		
 			 precharge(seq.ba,seq.addr);
  			`uvm_info("DDR_DRV_PRE",$sformatf("BA = %d, ADDR = %d",seq.ba, seq.addr), UVM_LOW);
 
      #`TRP; 
    	end
 
    else begin
      #`TRP;
    end
  	end*/
  end
 
  //Read
  	else if(seq.cmd == READ) begin
    read_cmnd(seq.ba, burst_addr);

	 //Auto precharge checking
	 	if(seq.auto_precharge)
				  vif.addr[10] <= 1;
		else
				  vif.addr[10] <= 1;

    #`TCL;

    `uvm_info("DDR_DRIVER","READ command issued",UVM_LOW)

	 	//Precharge
    	if(seq.auto_precharge) begin
			`uvm_info("DDR_DRIVER","Auto Precharge Enabled",UVM_LOW)
      	#`TRP;
    	end
 
    else begin
		precharge(seq.ba, seq.addr);
      #`TRP;
    end
  	 end
 
endtask

endclass
 
 
