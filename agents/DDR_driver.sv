// =============================================================================
//
// Component Name : DDR_driver
//
// =============================================================================

class DDR_driver extends uvm_driver #(DDR_seq_item); 
  `uvm_component_utils(DDR_driver)

  // ===========================================================================
  // Virtual Interface and Class Properties
  // ===========================================================================
  virtual DDR_interface vif;
  DDR_seq_item          seq;

  // State Tracking Variables
  bit       prev_cmd_was_act = 0;
  bit [1:0] prev_act_bank;
  
  typedef enum {ACTIVE, POWER_DOWN} ddr_state_e;
  ddr_state_e state = ACTIVE;

  // ===========================================================================
  // Component Constructor
  // ===========================================================================
  function new(string name = "DDR_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // ===========================================================================
  // Build Phase: Interface Retrieval & Configuration Display
  // ===========================================================================
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Display compilation data width configuration
    `ifdef X4
      `uvm_info("DRV_CFG", "COMPILED AS X4", UVM_NONE)
    `elsif X8
      `uvm_info("DRV_CFG", "COMPILED AS X8", UVM_NONE)
    `elsif X16
      `uvm_info("DRV_CFG", "COMPILED AS X16", UVM_NONE)
    `else
      `uvm_info("DRV_CFG", "NO WIDTH DEFINE FOUND", UVM_NONE)
    `endif

    `uvm_info("DRV_PARAMS", $sformatf("DATA_WIDTH=%0d COL_WIDTH=%0d ADDR_WIDTH=%0d", `DATA_WIDTH, `COL_WIDTH, `ADDR_WIDTH), UVM_NONE)

    // Retrieve Virtual Interface from Configuration Database
    if (!uvm_config_db #(virtual DDR_interface)::get(this, "", "DDR_interface", vif)) begin
      `uvm_fatal("DRV_NO_VIF", "Virtual interface 'vif' not found in uvm_config_db")
    end
  endfunction
   
  // ===========================================================================
  // Run Phase: Core Driver Execution Loop
  // ===========================================================================
  task run_phase(uvm_phase phase);
    // Safe initialization of physical signals
    bus_init();

    // Fetch primary item to complete memory initialization sequence
    seq_item_port.get_next_item(seq);
    ddr_init();
    drive_tx(seq);
    seq_item_port.item_done(); 

    // Set stable starting state
    state = ACTIVE;
    vif.ddr_drv_cb_t.cke <= 1;

    // Main Driver Loop running forever throughout simulation
    forever begin
      seq_item_port.get_next_item(seq);
      drive_tx(seq);
      seq_item_port.item_done(); 
    end
  endtask

  // ===========================================================================
  // Protocol Tasks
  // ===========================================================================

  // Task: Bus Initialization (Sets clean defaults)
  task bus_init;
    vif.ddr_drv_cb_t.ba          <= 0;
    vif.ddr_drv_cb_t.addr        <= 0;
    vif.ddr_drv_cb_t.dq_en       <= 1;
    vif.ddr_drv_cb_t.dq_en_data  <= 1'bz;
    vif.ddr_drv_cb_t.dqs_en      <= 1;
    vif.ddr_drv_cb_t.dqs_en_data <= 1'bz;
    vif.ddr_drv_cb_t.dm          <= 0;
    vif.ddr_drv_cb_t.cke         <= 0;
  endtask

  // Task: DDR Memory Initialization JEDEC Sequence
  task ddr_init();
    // CKE assert sequence
    @(vif.ddr_drv_cb_t); vif.ddr_drv_cb_t.cke <= 0;
    @(vif.ddr_drv_cb_t); vif.ddr_drv_cb_t.cke <= 1;
 
    // NOP Command
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 1;
    @(vif.ddr_drv_cb_t);

    // Precharge All
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.addr[10] <= 1;
 
    repeat(`TRP) @(vif.ddr_drv_cb_t);
    vif.ddr_drv_cb_t.addr[10] <= 0;
 
    // EMRS Enable (Enable DLL)
    vif.ddr_drv_cb_t.cs  <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.ba  <= 2'b01;
    vif.ddr_drv_cb_t.addr[0] <= 0;
 
    repeat(`TMRD) @(vif.ddr_drv_cb_t);

    // MRS (DLL Reset)
    vif.ddr_drv_cb_t.cs  <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.ba  <= 2'b00;
    vif.ddr_drv_cb_t.addr[8] <= 1;
 
    repeat(`TMRD) @(vif.ddr_drv_cb_t);

    // Wait Clock Cycles for DLL Reset (Driving NOP)
    repeat(`TDLL) begin
      @(vif.ddr_drv_cb_t);
      vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 1;
    end

    // Precharge All
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.addr[10] <= 1;
 
    repeat(`TRP) @(vif.ddr_drv_cb_t);
 		
    // First Auto Refresh
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 1;  
    repeat(`TRFC) @(vif.ddr_drv_cb_t);
 
    // Second Auto Refresh
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 1; 
    repeat(`TRFC) @(vif.ddr_drv_cb_t);
  endtask
 
  // Task: Mode Register Set (MRS)
  task mrs(bit dll_reset);
    bit [13:0] mode_reg; bit [2:0]  bl_bits; bit [2:0]  cl_bits;

    // Decode Configuration Burst Length
    `uvm_info("DRV_MRS", $sformatf("Configuring Burst Length: %0d", seq.cfg_bl), UVM_LOW)
    case (seq.cfg_bl)
      2:       bl_bits = 3'b001;
      4:       bl_bits = 3'b010;
      8:       bl_bits = 3'b011;
      default: begin
        bl_bits = 3'b000;
        `uvm_warning("DRV_MRS", "Invalid Burst Length configured!")
      end
    endcase

    // Decode Configuration CAS Latency
    `uvm_info("DRV_MRS", $sformatf("Configuring CAS Latency: %0d", seq.cfg_cl), UVM_LOW)
    case (seq.cfg_cl)
      2:       cl_bits = 3'b010;
      3:       cl_bits = 3'b011;
      default: begin
        cl_bits = 3'b010; // Defaulting to 2
        `uvm_warning("DRV_MRS", "Invalid CAS Latency! Defaulting to 2.")
      end
    endcase
 
    // Assemble Mode Register Array Mapping
    mode_reg        = 14'b0;
    mode_reg[2:0]   = bl_bits;
    mode_reg[3]     = seq.cfg_bt;
    mode_reg[6:4]   = cl_bits;
    mode_reg[8]     = dll_reset;
 
    // Drive MRS Command Pins
    vif.ddr_drv_cb_t.cs   <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.ba   <= 2'b00;
    vif.ddr_drv_cb_t.addr <= mode_reg;
 
    repeat(`TMRD) begin
      @(vif.ddr_drv_cb_t);
      nop();
    end
 
    `uvm_info("DRV_MRS", $sformatf("MRS Complete: BL=%0d CL=%0d BT=%0d DLL_Reset=%0d",seq.cfg_bl, seq.cfg_cl, seq.cfg_bt, dll_reset), UVM_LOW)
  endtask

  // Task: IDLE State Command (1xxx)	
  task idle();
    vif.ddr_drv_cb_t.cs <= 1; vif.ddr_drv_cb_t.ras <= 1'bx; vif.ddr_drv_cb_t.cas <= 1'bx; vif.ddr_drv_cb_t.we <= 1'bx;
  endtask

  // Task: NOP Command (0111)
  task nop();
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 1;
  endtask

  // Task: Activate Command (0011)
  task activate(bit [1:0] ba, bit [13:0] addr);
    vif.ddr_drv_cb_t.cs   <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 1;
    vif.ddr_drv_cb_t.ba   <= ba;
    vif.ddr_drv_cb_t.addr <= addr;
  endtask
 
  // Task: Write Command (0100)
  task write_cmnd(bit [1:0] ba, bit [`COL_WIDTH-1:0] addr, bit auto_precharge);
    vif.ddr_drv_cb_t.cs       <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.ba       <= ba;
    vif.ddr_drv_cb_t.addr     <= addr;
    vif.ddr_drv_cb_t.addr[10] <= auto_precharge;
  endtask

  // Task: Read Command (0101)
  task read_cmnd(bit [1:0] ba, bit [`COL_WIDTH-1:0] addr, bit auto_precharge); 
    vif.ddr_drv_cb_t.cs        <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 0; vif.ddr_drv_cb_t.we <= 1;
    vif.ddr_drv_cb_t.ba        <= ba;
    vif.ddr_drv_cb_t.addr[9:0] <= addr;
    vif.ddr_drv_cb_t.addr[10]  <= auto_precharge;
  endtask

  // Task: Burst Terminate Command (0110)
  task burst_terminate();
    vif.ddr_drv_cb_t.cs <= 0; vif.ddr_drv_cb_t.ras <= 1; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 0;
  endtask

  // Task: Precharge Command (0010)
  task precharge(bit [1:0] ba, bit [`COL_WIDTH-1:0] addr, bit precharge_all);
    vif.ddr_drv_cb_t.cs       <= 0; vif.ddr_drv_cb_t.ras <= 0; vif.ddr_drv_cb_t.cas <= 1; vif.ddr_drv_cb_t.we <= 0;
    vif.ddr_drv_cb_t.ba       <= ba;
    vif.ddr_drv_cb_t.addr     <= addr;
    vif.ddr_drv_cb_t.addr[10] <= precharge_all;
  endtask

  // Task: Power Down Processing
  task power_down();
    if (seq.cke == 0 && state != POWER_DOWN) begin
      state = POWER_DOWN;
      `uvm_info("DRV", "Entering Power-Down", UVM_LOW)
    end
    else if (seq.cke == 1 && state == POWER_DOWN) begin
      state = ACTIVE;
      `uvm_info("DRV", "Exiting Power-Down", UVM_LOW)
    end
 
    // Only drive CKE (NO other signal disturbance allowed)
    vif.ddr_drv_cb_t.cke <= seq.cke;
 
    `uvm_info("DRV_FSM", $sformatf("CKE=%0d STATE=%s", seq.cke, (state == POWER_DOWN) ? "POWER_DOWN" : "ACTIVE"), UVM_LOW)
  endtask

  // ===========================================================================
  // Transaction Processing Engine (Protocol Execution Case Breakdown)
  // ===========================================================================
  task drive_tx(DDR_seq_item seq);
    bit [`COL_WIDTH-1:0] burst_addr;
    burst_addr = seq.addr[`COL_WIDTH-1:0];

    // --- Power Down Management ---
    if(seq.do_power_down) begin
      power_down();
      `uvm_info("POWER_DOWN", "IN powerdown", UVM_LOW)
      return;
    end
 
    // --- MRS Command Processing ---
    else if (seq.cmd == MRS) begin 
      `uvm_info("DRV_TX_MRS", "Executing MRS Init Task Sequence", UVM_LOW)
      mrs(0);
    end

    // --- IDLE Command Processing ---
    else if (seq.cmd == IDLE) begin
      idle(); @(vif.ddr_drv_cb_t);
      `uvm_info("DRV_TX_IDLE", "Idle State Maintained", UVM_LOW)
    end
	
    // --- NOP Command Processing ---
    else if (seq.cmd == NOP) begin
      nop(); @(vif.ddr_drv_cb_t);
      `uvm_info("DRV_TX_NOP", "NOP Protocol Driven", UVM_LOW)
    end

    // --- ACTIVATE Command Processing ---
    else if (seq.cmd == ACTIVATE) begin
      // Previous command was ACT -> enforce tRRD structural constraint
      if (prev_cmd_was_act) begin
        `uvm_info("DRV_TRRD", $sformatf("Waiting tRRD between ACT BA=%0d and BA=%0d", prev_act_bank, seq.ba), UVM_LOW)
        repeat(`TRRD_DRV) begin
          @(vif.ddr_drv_cb_t); nop();
        end
      end

      activate(seq.ba, seq.addr);

      prev_cmd_was_act = 1;
      prev_act_bank    = seq.ba;

      `uvm_info("DRV_ACT", $sformatf("ACT BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
    end

    // --- WRITE Command Processing ---
    else if (seq.cmd == WRITE) begin
      if(prev_cmd_was_act) begin
        repeat(`TRCD_DRV) begin
          @(vif.ddr_drv_cb_t); nop();
        end
      end

      write_cmnd(seq.ba, burst_addr, seq.auto_precharge);
      vif.ddr_drv_cb_t.dqs_en_data <= 1'b0;
		
      `uvm_info("DRV_TX_WRITE", $sformatf("WRITE Issued -> BA=%0d COL=%0d AP=%0d", seq.ba, burst_addr, seq.auto_precharge), UVM_LOW)
	
      repeat(`TDQSS_DRV) @(vif.ddr_drv_cb_c);
      nop();

      vif.ddr_drv_cb_t.dq_en  <= 1;
      vif.ddr_drv_cb_t.dqs_en <= 1;
	 
      // Synchronous Burst Driving (Double Data Rate DDR Loop running POS and NEG)
      for (int i = 0; i < seq.cfg_bl; i += 2) begin
        int dm_even, dm_odd;
 
        case (seq.dm_mode)
          0:       begin dm_even = 0; dm_odd = 0; end
          1:       begin dm_even = 1; dm_odd = 1; end
          2:       begin dm_even = (i % 2);
                         dm_odd  = ((i + 1) % 2);
          end
          default: begin dm_even = 0; dm_odd = 0; end
        endcase
 
        // POS Edge Data Generation
        @(vif.ddr_drv_cb_t);
        vif.ddr_drv_cb_t.dq_en_data  <= seq.dq_burst[i];
        vif.ddr_drv_cb_t.dm          <= dm_even;
        seq.dm_array.push_back(dm_even);
        vif.ddr_drv_cb_t.dqs_en_data <= 1;
        `uvm_info("DRV_WRITE_POS", $sformatf("POS Data Driven: ADDR=%0d DATA[%0d]=%0d", burst_addr, i, seq.dq_burst[i]), UVM_LOW) 

        // NEG Edge Data Generation
        @(vif.ddr_drv_cb_c);
        vif.ddr_drv_cb_c.dq_en_data  <= seq.dq_burst[i+1];
        vif.ddr_drv_cb_c.dm          <= dm_odd;
        seq.dm_array.push_back(dm_odd);
        vif.ddr_drv_cb_c.dqs_en_data <= 0;
        `uvm_info("DRV_WRITE_NEG", $sformatf("NEG Data Driven: ADDR=%0d DATA[%0d]=%0d", burst_addr, i+1, seq.dq_burst[i+1]), UVM_LOW) 
      end 
			
      // Turn off physical bus drivers smoothly without creating bus contention
      fork
        begin
          @(vif.ddr_drv_cb_t); 
          vif.ddr_drv_cb_t.dq_en <= 0;
          vif.ddr_drv_cb_t.dm    <= 0;
        end
        begin
          @(vif.ddr_drv_cb_c); 
          vif.ddr_drv_cb_t.dqs_en      <= 0;
          vif.ddr_drv_cb_t.dqs_en_data <= 1'bz;
          vif.ddr_drv_cb_t.dq_en_data  <= 1'bz;
        end
      join

      // Handle Post-Write Protocol Wait Parameters
      if (seq.auto_precharge) begin
        `uvm_info("DRV_WRITE_AP", "Auto-Precharge active. Waiting tWR + tRP.", UVM_LOW)
        repeat(`TWR_DRV + `TRP_DRV) begin
          @(vif.ddr_drv_cb_t); nop();
        end			  
      end else begin
        `uvm_info("DRV_WRITE_NO_AP", "Standard Write. Waiting tWTR constraint.", UVM_LOW)
        repeat(`TWTR_DRV) @(vif.ddr_drv_cb_t);
      end
    end   

    // --- READ Command Processing ---
    else if (seq.cmd == READ) begin
      if(prev_cmd_was_act) begin
        repeat(`TRCD_DRV) begin
          @(vif.ddr_drv_cb_t); nop();
        end
      end

      read_cmnd(seq.ba, seq.addr, seq.auto_precharge);
      @(vif.ddr_drv_cb_t); nop();
      `uvm_info("DRV_TX_READ", $sformatf("READ Issued -> BA=%0d ADDR=%0d AP=%0d", seq.ba, seq.addr, seq.auto_precharge), UVM_LOW)
  
      // CAS Latency stall cycles
      repeat(`TCL_DRV) begin
        @(vif.ddr_drv_cb_t); nop();
      end
	
      if (!seq.bst_mode) begin	 
        repeat(seq.cfg_bl) begin  
          @(vif.ddr_drv_cb_t); nop();
        end
      end

      if (seq.auto_precharge) begin
        `uvm_info("DRV_READ_AP", "Auto-Precharge operating internally. Waiting tRP.", UVM_LOW)
        repeat(`TRP_DRV) begin
          @(vif.ddr_drv_cb_t); nop();
        end
      end
    end 

    // --- PRECHARGE Command Processing ---
    else if (seq.cmd == PRECHARGE) begin
      precharge(seq.ba, seq.addr, seq.precharge_all);
      if(seq.precharge_all)
        `uvm_info("DRV_PREALL", "PRECHRGE ALL CMD ", UVM_LOW)
      else
        `uvm_info("DRV_PRE", $sformatf("PRECHRGE BANK = %0d", seq.ba), UVM_LOW)

      repeat(`TRP_DRV) begin
        @(vif.ddr_drv_cb_t); nop();
      end
    end

    // --- BURST TERMINATE (BST) Command Processing ---
    else if (seq.cmd == BST) begin
      burst_terminate();
      `uvm_info("DRV_TX_BST", "BURST TERMINATE Command Driven", UVM_LOW)
      @(vif.ddr_drv_cb_t); nop();
    end
  endtask

endclass
