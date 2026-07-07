//=============================================================================
//
// Component Name : DDR_scoreboard
// 
//=============================================================================

// Macro declarations for custom analysis implementation ports
`uvm_analysis_imp_decl(_write_sb)
`uvm_analysis_imp_decl(_read_sb)

class DDR_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(DDR_scoreboard)

  //---------------------------------------------------------------------------
  // Analysis Ports
  //---------------------------------------------------------------------------
  uvm_analysis_imp_write_sb #(DDR_seq_item, DDR_scoreboard) sb_port_w;
  uvm_analysis_imp_read_sb  #(DDR_seq_item, DDR_scoreboard) sb_port_r;
 
  //---------------------------------------------------------------------------
  // Memory & Configuration Parameters
  //---------------------------------------------------------------------------
  bit [`COL_WIDTH-1:0] col;
 
  localparam ROW_DEPTH = (1 << `ADDR_WIDTH);
  localparam COL_DEPTH = (1 << `COL_WIDTH);
 
  // Internal Golden Memory: [Banks][Rows][Columns]
  reg [`DATA_WIDTH-1:0] mem [4][ROW_DEPTH][COL_DEPTH];
  
  // Bank Status Tracking
  bit                   bank_active[4];
  bit [`ADDR_WIDTH-1:0] active_row[4];
  
  // Mode Register Configurations
  int                   cfg_bl; // Burst Length
  int                   cfg_cl; // CAS Latency
  bit                   cfg_bt; // Burst Type (0: Sequential, 1: Interleaved)
 
  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new(string name = "DDR_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    sb_port_w = new("sb_port_w", this);
    sb_port_r = new("sb_port_r", this);
  endfunction : new

  //---------------------------------------------------------------------------
  // Function: burst_address
  //---------------------------------------------------------------------------
  function bit [63:0] burst_address(        
    bit [1:0]             ba,
    bit [`ADDR_WIDTH-1:0] row,
    bit [`COL_WIDTH-1:0]  start_col,
    int                   beat,
    int                   bl,
    bit                   bt
  );
    bit [`COL_WIDTH-1:0] mask;
    bit [`COL_WIDTH-1:0] base_col;
    bit [`COL_WIDTH-1:0] dynamic_col;

    mask     = bl - 1;
    base_col = start_col & ~mask;

    if(bt) begin
      // Interleaved Burst Structure
      dynamic_col = base_col | ((start_col ^ beat) & mask);
    end
    else begin
      // Sequential Burst Structure
      dynamic_col = base_col | ((start_col + beat) & mask);
    end

    return {38'b0, ba, row, dynamic_col};
  endfunction : burst_address

  //---------------------------------------------------------------------------
  // Function: compare
  //---------------------------------------------------------------------------
  function void compare(
    bit [63:0] addr,
    reg [31:0] actual,
    reg [31:0] expected
  );
    bit [1:0]             ba;
    bit [`ADDR_WIDTH-1:0] row;
    bit [`COL_WIDTH-1:0]  col_addr;

    ba       = addr[25:24];
    row      = addr[23:10];
    col_addr = addr[9:0];

    if(actual === expected) begin
      `uvm_info("SCB_PASS", $sformatf("MATCH BA=%0d ROW=%0d COL=%0d EXP=%0d ACT=%0d", ba, row, col_addr, expected, actual), UVM_LOW)
    end
    else begin
      `uvm_error("SCB_FAIL", $sformatf("MISMATCH BA=%0d ROW=%0d COL=%0d EXP=%0d ACT=%0d \n As per JESD DDR spec table no. 3, Burst order access is not following from RTL", ba, row, col_addr, expected, actual))
    end
  endfunction : compare

  //---------------------------------------------------------------------------
  // Function: write_write_sb
  //---------------------------------------------------------------------------
  function void write_write_sb(DDR_seq_item seq);
    bit [63:0]            target_addr;
    bit [`ADDR_WIDTH-1:0] row;
    bit [`COL_WIDTH-1:0]  col_addr;
 
    case(seq.cmd)
      MRS: begin
        cfg_bl = seq.cfg_bl;
        cfg_cl = seq.cfg_cl;
        cfg_bt = seq.cfg_bt;
        `uvm_info("SCB_MRS", $sformatf("BL=%0d CL=%0d BT=%s", cfg_bl, cfg_cl, cfg_bt ? "INTERLEAVED" : "SEQUENTIAL"), UVM_LOW)
      end
 
      ACTIVATE: begin
        active_row[seq.ba]  = seq.addr;
        bank_active[seq.ba] = 1'b1;
        `uvm_info("SCB_ACT", $sformatf("ACTIVATE BA=%0d ROW=%0d", seq.ba, seq.addr), UVM_LOW)
      end
 
      WRITE: begin
        if(!bank_active[seq.ba]) begin
          `uvm_error("SCB_BANK_CLOSED", $sformatf("WRITE issued ON CLOSED BANK BA=%0d COL=%0d. ACTIVATE REQUIRED", seq.ba, seq.addr))
          return;
        end
 
        row = active_row[seq.ba];

        for(int i = 0; i < cfg_bl; i++) begin 
          target_addr = burst_address(seq.ba, row, seq.addr[9:0], i, cfg_bl, cfg_bt);
          col_addr    = target_addr[`COL_WIDTH-1:0];

          // Check for Data Masking (DM)
          if(seq.dm_array.size() > i && seq.dm_array[i] == 1) begin
            `uvm_info("SCB_DM", $sformatf("WRITE MASKED BA=%0d ROW=%0d COL=%0d", seq.ba, row, col_addr), UVM_LOW)
            `uvm_info("SCB_DM", $sformatf("SCD_DM=%p", seq.dm_array[i]), UVM_LOW)
          end
          else begin
            mem[seq.ba][row][col_addr] = seq.dq_burst[i];
            `uvm_info("SCB_WRITE", $sformatf("WRITE BA=%0d ROW=%0d COL=%0d DATA=%0d", seq.ba, row, col_addr, seq.dq_burst[i]), UVM_LOW)
          end
        end

        // Auto Precharge management
        if(seq.auto_precharge) begin
          bank_active[seq.ba] = 1'b0;
          active_row[seq.ba]  = '0;
          `uvm_info("SCB_AP", $sformatf("AUTO PRECHARGE CLOSED BANK BA=%0d", seq.ba), UVM_LOW)
        end
      end 
      
      PRECHARGE: begin
        if(seq.addr[10]) begin
          // Precharge All Banks
          foreach(bank_active[i]) begin
            bank_active[i] = 1'b0;
            active_row[i]  = '0;
          end
          `uvm_info("SCB_PREALL", "PRECHARGE ALL BANKS", UVM_LOW)
        end
        else begin
          // Single Bank Precharge
          bank_active[seq.ba] = 1'b0;
          active_row[seq.ba]  = '0;
          `uvm_info("SCB_PRE", $sformatf("PRECHARGE BA=%0d", seq.ba), UVM_LOW)
        end
      end
    endcase
  endfunction : write_write_sb
 
  //---------------------------------------------------------------------------
  // Function: write_read_sb
  //---------------------------------------------------------------------------
  function void write_read_sb(DDR_seq_item seq);
    bit [63:0]            target_addr;
    reg [31:0]            expected;
    bit [`ADDR_WIDTH-1:0] row;
    bit [`COL_WIDTH-1:0]  col_addr;
    int                   beats_to_compare;
 
    if(seq.cmd != READ)
      return;
 
    if(!bank_active[seq.ba]) begin
      `uvm_error("SCB_BANK_CLOSED", $sformatf("READ issued ON CLOSED BANK BA=%0d COL=%0d. ACTIVATE REQUIRED", seq.ba, seq.addr))
      return;
    end
 
    row = active_row[seq.ba];
 
    `uvm_info("SCB_READ", $sformatf("READ BA=%0d ROW=%0d COL=%0d BT=%s BL=%0d", seq.ba, row, seq.addr[9:0], cfg_bt ? "INTERLEAVED" : "SEQUENTIAL", cfg_bl), UVM_LOW)
 
    // Handle Burst Terminate (BST) conditions
    if(seq.bst_detected) begin
      beats_to_compare = seq.burst_beats_received;
      `uvm_info("SCB_BST", $sformatf("BST detected. Comparing only %0d beats", beats_to_compare), UVM_LOW)
    end
    else begin
      beats_to_compare = cfg_bl;
    end

    // Loop through dynamic burst address map and check data
    for(int i = 0; i < beats_to_compare; i++) begin
      target_addr = burst_address(seq.ba, row, seq.addr[9:0], i, cfg_bl, cfg_bt);
      col_addr    = target_addr[`COL_WIDTH-1:0];
      expected    = mem[seq.ba][row][col_addr];

      compare(target_addr, seq.dq_burst[i], expected);
    end
 
    // Auto Precharge management
    if(seq.auto_precharge) begin
      bank_active[seq.ba] = 1'b0;
      active_row[seq.ba]  = '0;
      `uvm_info("SCB_AP", $sformatf("AUTO PRECHARGE CLOSED BANK BA=%0d", seq.ba), UVM_LOW)
    end
  endfunction : write_read_sb

endclass : DDR_scoreboard
