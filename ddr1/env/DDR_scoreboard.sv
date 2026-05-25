class DDR_scoreboard extends uvm_scoreboard; 
  `uvm_component_utils(DDR_scoreboard)
  uvm_analysis_imp #(DDR_seq_item, DDR_scoreboard) sb_port;

  typedef bit [25:0] ddr_addr_t;
  bit [31:0] mem [ddr_addr_t];
  bit [13:0] active_row [4];

  ddr_addr_t addr_sb;
 
  function new(string name = "DDR_scoreboard",uvm_component parent);
    super.new(name, parent);
    sb_port = new("sb_port", this);
  endfunction
 
  //Write method
  function void write(DDR_seq_item seq);
    bit [13:0] current_row; // Current active row
    bit [13:0] current_col; // Current activated column

	 //Activate
    if (seq.cs == 0 && seq.ras == 0 && seq.cas == 1 && seq.we == 1) begin
       active_row[seq.ba] = seq.addr[13:0];
      `uvm_info("SCB",$sformatf("ACT: Bank=%0d Row=%0d",seq.ba, seq.addr[13:0]),UVM_LOW)
    end
 

	 //Write
    else if (seq.cs == 0 && seq.ras == 1 && seq.cas == 0 && seq.we == 0) begin
      current_row = active_row[seq.ba];

      for (int i = 0; i < seq.cfg_bl; i++) begin
        current_col = seq.addr[13:0] + i;
        addr_sb = {seq.ba, current_row, current_col};
        mem[addr_sb] = seq.dq_burst[i];
//`uvm_info("SSCCBBBB",$sformatf( "BUrst length %0d", seq.cfg_bl),UVM_LOW)
	
 
        `uvm_info("SCB",$sformatf("WRITE: B=%0d R=%0d C=%0d DATA=%0d",seq.ba, current_row, current_col, seq.dq_burst[i]),UVM_LOW)
 
      end
 
    end
 
	//Read
    else if (seq.cs == 0 && seq.ras == 1 && seq.cas == 0 && seq.we == 1) begin
      current_row = active_row[seq.ba];
 
      for (int i = 0; i < seq.cfg_bl; i++) begin
        current_col = seq.addr[13:0] + i;
        addr_sb = {seq.ba, current_row, current_col};
		  //Check for address
        if (mem.exists(addr_sb)) begin
          if (mem[addr_sb] == seq.dq_burst[i]) begin
 
            `uvm_info("SCB",$sformatf("READ PASS: B=%0d R=%0d C=%0d EXP=%0d ACT=%0d",seq.ba, current_row, current_col,mem[addr_sb], seq.dq_burst[i]),UVM_LOW)
 
          end

          else begin
 
            `uvm_error("SCB",$sformatf("READ FAIL: B=%0d R=%0d C=%0d EXP=%0d ACT=%0d",seq.ba, current_row, current_col,mem[addr_sb], seq.dq_burst[i]))
          end
 
        end

        else begin
 
          `uvm_warning("SCB",$sformatf("UNINIT READ: B=%0d R=%0d C=%0d",seq.ba, current_row, current_col))
        end
 
      end
    end
 
  endfunction
 
endclass
 
/*class DDR_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(DDR_scoreboard)

  uvm_analysis_imp #(DDR_seq_item, DDR_scoreboard) sb_port;
 
  typedef bit [25:0] ddr_addr_t;
 
  bit [31:0] mem [ddr_addr_t];

 
  bit [13:0] active_row [4];

 
  ddr_addr_t addr;

 
  function new(string name = "DDR_scoreboard",
 
               uvm_component parent);
 
    super.new(name, parent);
 
    sb_port = new("sb_port", this);
 
  endfunction

 
  function void write(DDR_seq_item seq);

    bit [13:0] current_row;
 
    bit [13:0] current_col;

 
    if (seq.cs == 0 && seq.ras == 0 &&
 
        seq.cas == 1 && seq.we == 1) begin

      active_row[seq.ba] = seq.addr[13:0];

      `uvm_info("SCB",
 
        $sformatf("ACT: Bank=%0d Row=%0d",
 
        seq.ba, seq.addr[13:0]),
 
        UVM_LOW)

    end

 
    else if (seq.cs == 0 && seq.ras == 1 &&
 
             seq.cas == 0 && seq.we == 0) begin

      current_row = active_row[seq.ba];

      for (int i = 0; i < seq.cfg_bl; i++) begin

        current_col = seq.addr[13:0] + i;

        addr = {seq.ba, current_row, current_col};

        mem[addr] = seq.dq_burst[i];

        `uvm_info("SCB",
 
          $sformatf("WRITE: B=%0d R=%0d C=%0d DATA=%0d",
 
          seq.ba, current_row, current_col, seq.dq_burst[i]),
 
          UVM_LOW)

      end

    end

 
    else if (seq.cs == 0 && seq.ras == 1 &&
 
             seq.cas == 0 && seq.we == 1) begin

      current_row = active_row[seq.ba];

      for (int i = 0; i < seq.cfg_bl; i++) begin

        current_col = seq.addr[13:0] + i;

        addr = {seq.ba, current_row, current_col};

 
        if (mem.exists(addr)) begin

          if (mem[addr] == seq.dq_burst[i]) begin

            `uvm_info("SCB",
 
              $sformatf("READ PASS: B=%0d R=%0d C=%0d EXP=%0h ACT=%0h",
 
              seq.ba, current_row, current_col,
 
              mem[addr], seq.dq_burst[i]),
 
              UVM_LOW)

          end
 
          else begin

            `uvm_error("SCB",
 
              $sformatf("READ FAIL: B=%0d R=%0d C=%0d EXP=%0h ACT=%0h",
 
              seq.ba, current_row, current_col,
 
              mem[addr], seq.dq_burst[i]))

          end

        end
 
        else begin

          `uvm_warning("SCB",
 
            $sformatf("UNINIT READ: B=%0d R=%0d C=%0d",
 
            seq.ba, current_row, current_col))

        end

      end

    end

  endfunction

endclass

/*class DDR_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(DDR_scoreboard)
 
  uvm_analysis_imp #(DDR_seq_item, DDR_scoreboard) sb_port;
 
  // Each location is of 32 bit and consists of bank, row, column

 bit [31:0] mem [bit [1:0]][bit [13:0]][bit [9:0]];

  // 4 banks

  bit [13:0] active_bank [4];
 
  function new(string name = "DDR_scoreboard", uvm_component parent);

    super.new(name, parent);

    sb_port = new("sb_port", this);

  endfunction
 
  function void write(DDR_seq_item seq);

    bit [9:0] current_col;

    bit [13:0] current_row;
 
    // ACT: CS=0, RAS=0, CAS=1, WE=1

    if (seq.cs == 0 && seq.ras == 0 && seq.cas == 1 && seq.we == 1) begin
 
      active_bank[seq.ba] = seq.addr[13:0];

      `uvm_info("SCB",$sformatf("ACTIVATE: Bank %0d, Row %0d",seq.ba, seq.addr[13:0]),UVM_LOW)
 
    end
 
 
    // WRITE: CS=0, RAS=1, CAS=0, WE=0

    else if (seq.cs == 0 && seq.ras == 1 && seq.cas == 0 && seq.we == 0) begin
 
      current_row = active_bank[seq.ba];
 
      for (int i = 0; i < seq.cfg_bl; i++) begin
 
        current_col = seq.addr[9:0] + i;
 
        mem[seq.ba][current_row][current_col] = seq.dq_burst[i];
 
        `uvm_info("SCB",$sformatf("WRITE: Bank=%0d Row=%0d Col=%0d Data=%0d",seq.ba, current_row, current_col, seq.dq_burst[i]),UVM_LOW)

      end

    end

    // READ: CS=0, RAS=1, CAS=0, WE=1

    else if (seq.cs == 0 && seq.ras == 1 && seq.cas == 0 && seq.we == 1) begin
 
      current_row = active_bank[seq.ba];
 
      for (int i = 0; i < seq.cfg_bl; i++) begin
 
        current_col = seq.addr[13:0] + i;
 
        // Checking if bank, row and column exist

        if (mem.exists(seq.ba) && mem[seq.ba].exists(current_row) && mem[seq.ba][current_row].exists(current_col)) begin
 
          // Compare expected vs actual data

          if (mem[seq.ba][current_row][current_col] == seq.dq_burst[i]) begin

            `uvm_info("SCB",$sformatf("READ PASS: Bank=%0d Row=%0d Col=%0d Data=%0d",seq.ba, current_row, current_col, seq.dq_burst[i]),UVM_LOW)

          end

          else begin

            `uvm_error("SCB",$sformatf("READ FAIL: Bank=%0d Row=%0d Col=%0d Exp=%0d Act=%0d",seq.ba,current_row,current_col,mem[seq.ba][current_row][current_col],seq.dq_burst[i]))

          end

        end

        else begin

          `uvm_warning("SCB",$sformatf("READ UNINITIALIZED: Bank=%0d Row=%0d Col=%0d",seq.ba, current_row, current_col))

        end

      end

    end

  endfunction

endclass*/

  
