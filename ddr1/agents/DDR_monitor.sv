//==============================================================================
// Component Name : DDR_monitor
//==============================================================================

class DDR_monitor extends uvm_monitor;
  `uvm_component_utils(DDR_monitor)

  // Interface and Analysis Ports
  virtual DDR_interface vif;
  uvm_analysis_port #(DDR_seq_item) mon_ap_write;
  uvm_analysis_port #(DDR_seq_item) mon_ap_read;
  
  // Internal Tracking Variables
  DDR_seq_item seq;
  bit [13:0] mode_reg;
  bit [2:0]  bl_bits;
  bit [2:0]  cl_bits;
  int        burst_length;
  int        cas_latency;
  bit        burst_type;
  bit        dll_reset;
  bit        bst_detected;
  int        beat_count;

  // Timing Counters
  int tmrd_cnt;
  int trrd_cnt;
  int trcd_cnt[4];
  int tras_cnt[4];
  int trp_cnt[4];
  int trc_cnt[4];
  int twtr_cnt[4];
  int twr_cnt[4];
  int tcl_cnt[4];
  int tdqss_cnt[4];
  bit [1:0] prev_act_bank;

  // Command State Tracking
  typedef enum bit [2:0] {
    CMD_IDLE,  
    CMD_MRS,
    CMD_ACT,   
    CMD_READ,
    CMD_WRITE,
    CMD_PRE   
  } cmd_t;
  cmd_t prev_cmd[4];

  // Constructor
  function new(string name="DDR_monitor", uvm_component parent=null);
    super.new(name, parent);
    mon_ap_write = new("mon_ap_write", this);
    mon_ap_read  = new("mon_ap_read", this);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual DDR_interface)::get(this, "", "DDR_interface", vif))
      `uvm_fatal("MON", "NO INTERFACE")
    
    // Initialize timing counters
    tmrd_cnt = -1;
    trrd_cnt = -1;
    foreach(trcd_cnt[i]) begin
      trcd_cnt[i]  = -1;
      tras_cnt[i]  = -1;
      trp_cnt[i]   = -1;
      trc_cnt[i]   = -1;
      twtr_cnt[i]  = -1;
      tdqss_cnt[i] = -1;
      tcl_cnt[i]   = -1;
      twr_cnt[i]   = -1;
      prev_cmd[i]  = CMD_IDLE;
    end
  endfunction

  // Run Phase
  task run_phase(uvm_phase phase);
    fork
      // Thread 1: Background Timing Counter Incrementer
      begin
        forever begin
          @(vif.ddr_mon_cb_t);
          foreach(trcd_cnt[i]) begin
            if(trcd_cnt[i]  != -1) trcd_cnt[i]++;
            if(tras_cnt[i]  != -1) tras_cnt[i]++;
            if(trp_cnt[i]   != -1) trp_cnt[i]++;
            if(trc_cnt[i]   != -1) trc_cnt[i]++;
            if(twtr_cnt[i]  != -1) twtr_cnt[i]++;
            if(tcl_cnt[i]   != -1) tcl_cnt[i]++;
            if(tdqss_cnt[i] != -1) tdqss_cnt[i]++;
          end
          if(tmrd_cnt != -1) tmrd_cnt++;
          if(trrd_cnt != -1) trrd_cnt++;
        end
      end
      
      // Thread 2: Command Sampling and Protocol Checking
      begin
        forever begin
          @(vif.ddr_mon_cb_t);
          
          //MRS COMMAND
          if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 0 && vif.ddr_mon_cb_t.cas == 0 && vif.ddr_mon_cb_t.we == 0 && vif.ddr_mon_cb_t.ba == 2'b00) begin
            `uvm_info("TMRD_CHECK", $sformatf("tmrd_cnt=%0d", tmrd_cnt), UVM_LOW)
            if(tmrd_cnt != -1 && tmrd_cnt < `TMRD)
              `uvm_error("TMRD_VIOLATION", $sformatf("tMRD violation! Required=2 Actual=%0d", tmrd_cnt))
            
            @(vif.ddr_mon_cb_t);
            seq        = DDR_seq_item::type_id::create("seq");
            seq.cmd    = MRS;
            mode_reg   = vif.ddr_mon_cb_t.addr;
            bl_bits    = mode_reg[2:0];
            burst_type = mode_reg[3];
            cl_bits    = mode_reg[6:4];
            dll_reset  = mode_reg[8];
            
            case(bl_bits)
              3'b001:  burst_length = 2;
              3'b010:  burst_length = 4;
              3'b011:  burst_length = 8;
              default: burst_length = 2;
            endcase
            
            case(cl_bits)
              3'b010:  cas_latency = 2;
              3'b011:  cas_latency = 3;
              default: cas_latency = 2;
            endcase
            
            seq.cfg_bl = burst_length;
            seq.cfg_cl = cas_latency;
            seq.cfg_bt = burst_type;
            `uvm_info("MON_MRS", $sformatf("BL=%0d CL=%0d BT=%0d DLL=%0d", burst_length, cas_latency, burst_type, dll_reset), UVM_LOW)
            mon_ap_write.write(seq);
            tmrd_cnt = 0;
            foreach(prev_cmd[i]) prev_cmd[i] = CMD_IDLE;
          end
          
          //  ACTIVE COMMAND 
          else if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 0 && vif.ddr_mon_cb_t.cas == 1 && vif.ddr_mon_cb_t.we == 1) begin
            bit [1:0] curr_bank = vif.ddr_mon_cb_t.ba;
            
            case(prev_cmd[curr_bank])
              CMD_IDLE: begin end
              CMD_PRE: begin
                if(trp_cnt[curr_bank] != -1 && trp_cnt[curr_bank] < `TRP)
                  `uvm_error("TRP_VIOLATION", $sformatf("tRP violation! ACT issued too fast after PRE on BA=%0d Actual=%0d", curr_bank, trp_cnt[curr_bank]))
              end
              CMD_ACT: begin
                if(trc_cnt[curr_bank] != -1 && trc_cnt[curr_bank] < `TRC)
                  `uvm_error("TRC_VIOLATION", $sformatf("tRC violation! Consecutive ACT on open BA=%0d without a proper timind delay. Actual=%0d", curr_bank, trc_cnt[curr_bank]))
              end
            endcase
            
            if(trrd_cnt != -1 && prev_act_bank != curr_bank && trrd_cnt < `TRRD)
              `uvm_error("TRRD_VIOLATION", $sformatf("tRRD violation between bank %0d and %0d! Actual=%0d", prev_act_bank, curr_bank, trrd_cnt))

            seq        = DDR_seq_item::type_id::create("seq");
            seq.cmd    = ACTIVATE;
            seq.ba     = curr_bank;
            seq.addr   = vif.ddr_mon_cb_t.addr;
            seq.cfg_bl = burst_length;
            mon_ap_write.write(seq);
            
            trcd_cnt[curr_bank] = 0;
            tras_cnt[curr_bank] = 0;
            trc_cnt[curr_bank]  = 0;
            prev_act_bank       = curr_bank;
            trrd_cnt            = 0;
            prev_cmd[curr_bank] = CMD_ACT;
            `uvm_info("MON_ACTIVATE",$sformatf("BA=%0d ADDR=%0d",seq.ba,seq.addr),UVM_LOW)
          end
          
          //  WRITE COMMAND 
          else if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 1 && vif.ddr_mon_cb_t.cas == 0 && vif.ddr_mon_cb_t.we == 0) begin
            bit [1:0] curr_bank = vif.ddr_mon_cb_t.ba;
            DDR_seq_item wr_tr  = DDR_seq_item::type_id::create("wr_tr");
           
            case(prev_cmd[curr_bank])
              CMD_ACT: begin
                if(trcd_cnt[curr_bank] != -1 && trcd_cnt[curr_bank] < `TRCD)
                  `uvm_error("TRCD_VIOLATION_WRITE", $sformatf("tRCD violation! WRITE sent too quickly after ACT on BA=%0d Actual=%0d", curr_bank, trcd_cnt[curr_bank]))
              end
	     
            endcase
            
            wr_tr.cmd            = WRITE;
            wr_tr.ba             = curr_bank;
            wr_tr.addr           = vif.ddr_mon_cb_t.addr;
            wr_tr.cfg_bl         = burst_length;
            wr_tr.auto_precharge = vif.ddr_mon_cb_t.addr[10]; 

            `uvm_info("MON_WRITE",$sformatf("WRITE BA=%0d ADDR=%0d AUTO_PRECHARGE=%0d",wr_tr.ba, wr_tr.addr, wr_tr.auto_precharge),UVM_LOW)
 		
            fork
              DDR_seq_item tr = wr_tr;
              int bl = burst_length;
              bit [1:0] bk = curr_bank;
              begin
                @(posedge vif.dqs);
                if(tdqss_cnt[bk] != -1 && tdqss_cnt[bk] < `TDQSS)
                  `uvm_error("TDQSS_VIOLATION", $sformatf("tDQSS violation BA=%0d Required=1 Actual=%0d", bk, tdqss_cnt[bk]))
                
                for(int i=0; i<bl; i++) begin
                  if(i%2==0) begin
                    @(vif.ddr_mon_cb_c);
                    tr.dq_burst[i] = vif.ddr_mon_cb_c.dq;
                    tr.dm = vif.ddr_mon_cb_c.dm;
                    tr.dm_array.push_back(vif.ddr_mon_cb_c.dm);
                  end else begin
                    @(vif.ddr_mon_cb_t);
                    tr.dq_burst[i] = vif.ddr_mon_cb_t.dq;
                    tr.dm = vif.ddr_mon_cb_t.dm;
                    tr.dm_array.push_back(vif.ddr_mon_cb_t.dm);
                  end
                  `uvm_info("MON_write_DATA", $sformatf("Stored Data = %0d", tr.dq_burst[i]), UVM_LOW)
                end
                mon_ap_write.write(tr);
                twtr_cnt[bk] = 0; 
              end
            join_none
            prev_cmd[curr_bank] = CMD_WRITE;
          end

          //  READ COMMAND
          else if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 1 && vif.ddr_mon_cb_t.cas == 0 && vif.ddr_mon_cb_t.we == 1) begin
            bit [1:0] curr_bank = vif.ddr_mon_cb_t.ba;
            DDR_seq_item rd_tr  = DDR_seq_item::type_id::create("rd_tr");
            
            case(prev_cmd[curr_bank])
              CMD_ACT: begin
                if(trcd_cnt[curr_bank] != -1 && trcd_cnt[curr_bank] < `TRCD)
                  `uvm_error("TRCD_VIOLATION_READ", $sformatf("tRCD violation before READ on BA=%0d Actual=%0d", curr_bank, trcd_cnt[curr_bank]))
              end
              CMD_WRITE: begin
                if(twtr_cnt[curr_bank] != -1 && twtr_cnt[curr_bank] < `TWTR)
                  `uvm_error("TWTR_VIOLATION", $sformatf("tWTR violation! READ sent too close following a WRITE sequence on BA=%0d Actual=%0d", curr_bank, twtr_cnt[curr_bank]))
              end
            endcase

            rd_tr.cmd            = READ;
            rd_tr.ba             = curr_bank;
            rd_tr.addr           = vif.ddr_mon_cb_t.addr;
            rd_tr.cfg_bl         = burst_length;
            tcl_cnt[curr_bank]   = 0;
            rd_tr.auto_precharge = vif.ddr_mon_cb_t.addr[10]; 
		  
            `uvm_info("MON_READ",$sformatf("READ BA=%0d ADDR=%0d AUTO_PRECHARGE=%0d",rd_tr.ba, rd_tr.addr, rd_tr.auto_precharge),UVM_LOW)
            rd_tr.bst_detected   = 0;
            rd_tr.burst_beats_received = 0;
            beat_count           = 0;

            fork
              DDR_seq_item tr = rd_tr;
              int cl = cas_latency;
              int bl = burst_length;
              bit [1:0] bk = curr_bank;
              begin
                repeat(cl) @(vif.ddr_mon_cb_t);
                if(tcl_cnt[bk] != -1 && tcl_cnt[bk] < cl)
                  `uvm_error("TCL_VIOLATION", $sformatf("tCL violation BA=%0d Required=%0d Actual=%0d", bk, cl, tcl_cnt[bk]))
                $display("CAS LATENCY in MON %0d", cl);
                
                @(vif.ddr_mon_cb_c);
                for(int i=0; i<bl; i++) begin
		// bst terminate	
                  if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 1 && vif.ddr_mon_cb_t.cas == 1 && vif.ddr_mon_cb_t.we == 0) begin
                    rd_tr.cmd = BST;
                    rd_tr.bst_detected = 1;
                    rd_tr.burst_beats_received = beat_count;
                    `uvm_info("MON_BST",$sformatf("BST detected after %0d beats",beat_count),UVM_LOW)
                    break;
                  end

                  if(i%2==0) begin
                    tr.dq_burst[i] = vif.ddr_mon_cb_c.dq;
                    @(vif.ddr_mon_cb_c);
                  end else begin
                    tr.dq_burst[i] = vif.ddr_mon_cb_t.dq;
                    @(vif.ddr_mon_cb_t);
                  end
                  beat_count++;
                  `uvm_info("MON_READ_DATA", $sformatf("Stored Data = %0d", tr.dq_burst[i]), UVM_LOW)
                end
		
                if(!rd_tr.bst_detected)
                  rd_tr.burst_beats_received = bl;
                mon_ap_read.write(tr);
              end
            join_none
            prev_cmd[curr_bank] = CMD_READ;
          end
          
          //  PRECHARGE COMMAND 
          else if(vif.ddr_mon_cb_t.cs == 0 && vif.ddr_mon_cb_t.ras == 0 && vif.ddr_mon_cb_t.cas == 1 && vif.ddr_mon_cb_t.we == 0) begin
            bit [1:0] curr_bank = vif.ddr_mon_cb_t.ba;
            
            case(prev_cmd[curr_bank])
              CMD_ACT: begin
                if(tras_cnt[curr_bank] != -1 && tras_cnt[curr_bank] < `TRAS)
                  `uvm_error("TRAS_VIOLATION", $sformatf("tRAS violation! PRECHARGE issued too fast after ACT on BA=%0d Actual=%0d", curr_bank, tras_cnt[curr_bank]))
              end
              CMD_WRITE: begin
                if(twr_cnt[curr_bank] != -1 && twr_cnt[curr_bank] < `TWR)
                  `uvm_error("TWR_VIOLATION", $sformatf("tWR violation! PRECHARGE issued before write recovery complete on BA=%0d Actual=%0d", curr_bank, twtr_cnt[curr_bank]))
              end
            endcase
            
            seq      = DDR_seq_item::type_id::create("seq");
            seq.cmd  = PRECHARGE;
            seq.ba   = curr_bank;
            seq.addr = vif.ddr_mon_cb_t.addr;
            mon_ap_write.write(seq);
            
            trp_cnt[curr_bank]  = 0;
            prev_cmd[curr_bank] = CMD_PRE;
            `uvm_info("MON_PRECHARGE",$sformatf("precharge issued curr_bank=%0d ",curr_bank),UVM_LOW)
          end
        end
      end
    join
  endtask
endclass
