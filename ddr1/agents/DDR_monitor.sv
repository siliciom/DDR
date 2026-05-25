/*class DDR_monitor extends uvm_monitor;
 
  `uvm_component_utils(DDR_monitor)
 
  virtual DDR_interface vif;

  uvm_analysis_port #(DDR_seq_item) mon_ap;

  DDR_seq_item seq;
 
  bit [13:0] mode_reg;

  bit [2:0]  bl_bits;

  bit [2:0]  cl_bits;
 
  int burst_length;

  int cas_latency;
 
  bit burst_type;

  bit dll_reset;
 
  // Constructor

  function new(string name = "DDR_monitor", uvm_component parent = null);

    super.new(name, parent);

    mon_ap = new("mon_ap", this);

  endfunction
 
  // Build Phase

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
 
    `uvm_info("MON","Monitor capturing DDR transactions",UVM_LOW)
 
    // Get Interface

    if (!uvm_config_db#(virtual DDR_interface)::get(  this, "", "DDR_interface", vif))

    begin

      `uvm_fatal("MON", "NO INTERFACE")

    end

  endfunction
 
  // Run Phase

  task run_phase(uvm_phase phase);
 
    forever begin
 
      @(posedge vif.ck_t);
 
      // Create fresh sequence item

      seq = DDR_seq_item::type_id::create("seq");
 
      // Capture common signals

      seq.cke  = vif.cke;

      seq.cs   = vif.cs;

      seq.ras  = vif.ras;

      seq.cas  = vif.cas;

      seq.we   = vif.we;

      seq.ba   = vif.ba;

      seq.addr = vif.addr;

      seq.dq   = vif.dq;

      seq.dm   = vif.dm;
 

      // MRS COMMAND


      if (vif.cs  == 0 &&  vif.ras == 0 && vif.cas == 0 && vif.we  == 0 && vif.ba==2'b00)

      begin

        mode_reg   = vif.addr;
 
        bl_bits    = mode_reg[2:0];

        burst_type = mode_reg[3];

        cl_bits    = mode_reg[6:4];

        dll_reset  = mode_reg[8];
 
        // Decode Burst Length

        case (bl_bits)

          3'b001: burst_length = 2;

          3'b010: burst_length = 4;

          3'b011: burst_length = 8;

          default: burst_length = 4;

        endcase

        `uvm_info("MON" ,$sformatf("MRS burst_length=%0d",burst_length),UVM_LOW)

        // Decode CAS Latency

        case (cl_bits)

          3'b010: cas_latency = 2;

          3'b011: cas_latency = 3;

          default: cas_latency = 2;

        endcase
 
        `uvm_info("MON_MRS",$sformatf( "MRS dll_reset=%0b bl=%0d cl=%0d bt=%0b",dll_reset,burst_length,cas_latency, burst_type),UVM_LOW)
 
        mon_ap.write(seq);
 
      end
 
      // NOP COMMAND

      else if (vif.cs  == 0 && vif.ras == 1 &&vif.cas == 1 &&vif.we  == 1)

      begin
 
        `uvm_info("MON", "NOP command", UVM_LOW)
 
      end
 
      // ACTIVE COMMAND

      else if (vif.cs  == 0 && vif.ras == 0 && vif.cas == 1 && vif.we  == 1)

      begin
 
        `uvm_info("MON",$sformatf( "ACT ba=%0d row_addr=%0d",seq.ba,  seq.addr), UVM_LOW)
 
        #`TRCD;
 
        mon_ap.write(seq);
 
      end
 
      // WRITE COMMAND

      else if (vif.cs  == 0 &&  vif.ras == 1 && vif.cas == 0 && vif.we  == 0)

      begin
 
         //@(vif.;
 
        #`TDQSS;
	//#`TCK4;
 
         //@(vif.;
 
	 
         @(posedge vif.ck_t);
        for (int i = 0; i < burst_length; i++) begin
 
//          @(vif.dqs);
         @(posedge vif.ck_t);
//	#`TCK4;
          seq.dq_burst[i] = vif.dq;
 
          `uvm_info("MON",$sformatf( "WRITE ba=%0d addr=%0d dq_burst[%0d]=%0d", seq.ba,seq.addr + i,i, seq.dq_burst[i]),UVM_LOW)
	`uvm_info("MON",$sformatf( " i count =%0d",i),UVM_LOW)	 
 
        
       // @(posedge vif.ck_t);

        end
 
     //    @(vif.;
         //@(vif.dqs);
      //    @(vif.dqs);

        mon_ap.write(seq);
 
      end
 
      // READ COMMAND

      else if (vif.cs  == 0 &&  vif.ras == 1 &&  vif.cas == 0 &&vif.we  == 1)

      begin
 
 
        for (int i = 0; i < burst_length; i++) begin
 
         // @(vif.;
 
          #`TCL;
 
          seq.dq_burst[i] = vif.dq;
 
          `uvm_info("MON", $sformatf(   "READ ba=%0d addr=%0d dq[%0d]=%0d",seq.ba,seq.addr + i,i,  seq.dq_burst[i]),UVM_LOW)
 
        end
 
        mon_ap.write(seq);
 
      end
 
      // PRECHARGE COMMAND

      else if (vif.cs  == 0&& vif.ras == 0 &&vif.cas == 1 && vif.we  == 0)

      begin
 
        `uvm_info("MON",  $sformatf("PRECHARGE ba=%0d addr=%0d",seq.ba,  seq.addr), UVM_LOW)
 
        mon_ap.write(seq);
 
      end
 
    end
 
  endtask
 
endclass*/

class DDR_monitor extends uvm_monitor;
 
  `uvm_component_utils(DDR_monitor)
 
  virtual DDR_interface vif;

  uvm_analysis_port #(DDR_seq_item) mon_ap;

  DDR_seq_item seq;
 
  bit [13:0] mode_reg;

  bit [2:0]  bl_bits;

  bit [2:0]  cl_bits;
 
  int burst_length;

  int cas_latency;
 
  bit burst_type;

  bit dll_reset;
 
  // Constructor

  function new(string name = "DDR_monitor", uvm_component parent = null);

    super.new(name, parent);

    mon_ap = new("mon_ap", this);

  endfunction
 
  // Build Phase

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);
 
    `uvm_info("MON","Monitor capturing DDR transactions",UVM_LOW)
 
    // Get Interface

    if (!uvm_config_db#(virtual DDR_interface)::get(  this, "", "DDR_interface", vif))

    begin

      `uvm_fatal("MON", "NO INTERFACE")

    end

  endfunction
 
  // Run Phase

  task run_phase(uvm_phase phase);
 
    forever begin
 
      @(posedge vif.ck_t);
 
      // Create fresh sequence item

      seq = DDR_seq_item::type_id::create("seq");
 
      // Capture common signals

      seq.cke  = vif.cke;

      seq.cs   = vif.cs;

      seq.ras  = vif.ras;

      seq.cas  = vif.cas;

      seq.we   = vif.we;

      seq.ba   = vif.ba;

      seq.addr = vif.addr;

      seq.dq   = vif.dq;

      seq.dm   = vif.dm;
 


      // MRS COMMAND


      if (vif.cs  == 0 &&  vif.ras == 0 && vif.cas == 0 && vif.we  == 0 && vif.ba==2'b00)

      begin

        mode_reg   = vif.addr;
 
        bl_bits    = mode_reg[2:0];

        burst_type = mode_reg[3];

        cl_bits    = mode_reg[6:4];

        dll_reset  = mode_reg[8];
 
        // Decode Burst Length

        case (bl_bits)

          3'b001: burst_length = 2;

          3'b010: burst_length = 4;

          3'b011: burst_length = 8;

          default: burst_length = 0;
	  endcase
          seq.cfg_bl = burst_length;

        `uvm_info("MON" ,$sformatf("MRS burst_length=%0d",burst_length),UVM_LOW)

        // Decode CAS Latency

        case (cl_bits)

          3'b010: cas_latency = 2;

          3'b011: cas_latency = 3;

          default: cas_latency = 0;

        endcase
 
        `uvm_info("MON_MRS",$sformatf( "MRS dll_reset=%0b bl=%0d cl=%0d bt=%0b",dll_reset,burst_length,cas_latency, burst_type),UVM_LOW)
 
        mon_ap.write(seq);
 
      end
 
      // NOP COMMAND

 
      // ACTIVE COMMAND

      else if (vif.cs  == 0 && vif.ras == 0 && vif.cas == 1 && vif.we  == 1)

      begin
 
        `uvm_info("MON",$sformatf( "ACT ba=%0d row_addr=%0d",seq.ba,  seq.addr), UVM_LOW)
 
        #`TRCD;
 
        mon_ap.write(seq);
`uvm_info("MON", $sformatf("Sending READ to SCB: cmd=%0d ba=%0d addr=%0d cfg_bl=%0d dq_burst[0]=%0d",
                             seq.cmd, seq.ba, seq.addr, seq.cfg_bl, seq.dq_burst[0]), UVM_LOW) 
 
      end
 
      // WRITE COMMAND

      else if (vif.cs  == 0 &&  vif.ras == 1 && vif.cas == 0 && vif.we  == 0)
      begin
	     //  seq.cmd= WRITE;// modified
		  seq.ba = vif.ba;
		  seq.addr = vif.addr;

 
      // #`TDQSS;
		  //

      //	@(vif.dqs);
 
        for (int i = 0; i < burst_length; i++) begin
	//	 #`TDQSS;

                @(vif.dqs);

          seq.dq_burst[i] = vif.dq;
 
          `uvm_info("MON",$sformatf( "WRITE ba=%0d addr=%0d dq_burst[%0d]=%0d", seq.ba,seq.addr + i,i, seq.dq_burst[i]),UVM_LOW)
 
	  seq.cfg_bl = burst_length;

 
        // @(vif.dqs);

        end
 		     `uvm_info("MON",$sformatf("sending WRITE to SCB"),UVM_LOW)

       // mon_ap.write(seq);
     `uvm_info("MON", $sformatf("Sending READ to SCB: cmd=%0d ba=%0d addr=%0d cfg_bl=%0d dq_burst[0]=%0d",
                             seq.cmd, seq.ba, seq.addr, seq.cfg_bl, seq.dq_burst[0]), UVM_LOW)
			    seq.cfg_bl = burst_length;
      end
 
      // READ COMMAND

      else if (vif.cs  == 0 &&  vif.ras == 1 &&  vif.cas == 0 &&vif.we  == 1)
  
      begin
 
 
        for (int i = 0; i < burst_length; i++) begin
 
 
        //  #`TCL;
 
          seq.dq_burst[i] = vif.dq;
 
          `uvm_info("MON", $sformatf(   "READ ba=%0d addr=%0d dq[%0d]=%0d",seq.ba,seq.addr + i,i,  seq.dq_burst[i]),UVM_LOW)
	  @(vif.dqs);
 
        end
 
       // mon_ap.write(seq);
 
      end
 
      // PRECHARGE COMMAND

      else if (vif.cs  == 0&& vif.ras == 0 &&vif.cas == 1 && vif.we  == 0)

      begin
 
        `uvm_info("MON",  $sformatf("PRECHARGE ba=%0d addr=%0d",seq.ba,  seq.addr), UVM_LOW)
 
        mon_ap.write(seq);
 
      end
// seq.cfg_bl = burst_length;
  mon_ap.write(seq);

    end
 mon_ap.write(seq);
  endtask
 
endclass
 




