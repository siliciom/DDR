module ddr_device #(	parameter addr_width 	=14, 		
				parameter data_width 	=16,
				parameter col_width 	=10)

(
    input  logic        ck_t,
    input  logic        ck_c,
    input  logic        cke,
    input  logic        cs_n,
    input  logic        ras_n,
    input  logic        cas_n,
    input  logic        we_n,
    input  logic        dm,
    inout  wire         dqs,
    input  logic [1:0]  ba,
    input  logic [addr_width - 1 : 0] addr,
    inout  wire [data_width - 1 : 0]  dq
);

import ddr_pkg::*;

cmd_t cmd;

ddr_command_decoder u_cmd_decoder
(
    .cs_n(cs_n),
    .ras_n(ras_n),
    .cas_n(cas_n),
    .we_n (we_n),
    .cmd  (cmd)
);

burst_length_t burst_length;
logic burst_interleaved;
logic [2:0] cas_latency;
logic load_mrs;

ddr_mode_register u_mrs
(
    .clk(ck_t),
    .rst_n(cke),
    .load(load_mrs),
    .addr(addr),
    .burst_length(burst_length),
    .burst_interleaved(burst_interleaved),
    .cas_latency(cas_latency)
);

logic [data_width - 1 : 0] mem [0:3][0:16383][0:((2**col_width) - 1)];

typedef struct {
   logic active;
   logic [13:0] open_row;
   logic auto_precharge_pending;
   logic read_pending;
   logic write_pending;
   logic [7:0] trcd_cnt;
   logic [7:0] tras_cnt;
   logic [7:0] trp_cnt;
   logic [7:0] twr_cnt;
} bank_state_t_local;

bank_state_t_local bank[4];

logic [1:0] active_bank;
logic [13:0] active_row;
logic [col_width - 1 : 0] active_col;
logic auto_precharge;
logic burst_running;
logic read_burst;
logic write_burst;

logic [3:0] burst_count;
logic [3:0] burst_limit;

always_comb begin
   case(burst_length)
      BL2: burst_limit = 2;
      BL4: burst_limit = 4;
      BL8: burst_limit = 8;
      default: burst_limit = 4;
   endcase
end

logic [data_width - 1:0] dq_out;
logic dq_oe;
wire [data_width - 1:0] dq_in;

assign dq_in = dq;
assign dq = dq_oe ? dq_out : 16'hzzzz;

// DQS: driven LOW/HIGH by device during reads (DDR strobe), input during writes.
logic dqs_out;
logic dqs_oe;
assign dqs = dqs_oe ? dqs_out : 1'bz;

// Write data is captured on both DQS edges (controller drives DQS during writes).

integer i;

always @(posedge ck_t or posedge ck_c) begin
   for(i=0;i<4;i++) begin
			  if(bank[i].trcd_cnt) begin
//	$display($time,"TRCD COUNT FROM DDR DEVICE DQS FROM FOR LOOP RTL %0d",bank[i].trcd_cnt);
	      bank[i].trcd_cnt--;
//			$display($time,"TRCD COUNT FROM DDR DEVICE DQS FROM FOR LOOP RTL AFTER DECREM %0d",bank[i].trcd_cnt);
 end
      if(bank[i].tras_cnt) bank[i].tras_cnt--;
      if(bank[i].trp_cnt)  bank[i].trp_cnt--;
      if(bank[i].twr_cnt) begin  
	$display($time,"TWR COUNT FROM DDR DEVICE DQS FROM FOR LOOP RTL %0d",bank[i].twr_cnt);
	      bank[i].twr_cnt--;
			$display($time,"TWR COUNT FROM DDR DEVICE DQS FROM FOR LOOP RTL AFTER DECREM %0d",bank[i].twr_cnt);
		end
   end
end

task automatic check_trcd(input logic [1:0] bank_id);
begin
//	$display($time,"TRCD COUNT FROM DDR DEVICE DQS RTL %0d",bank[bank_id].trcd_cnt);
   assert(bank[bank_id].trcd_cnt == 0)
   else $error("tRCD violation");
end
endtask

typedef enum logic [3:0] {
   IDLE,
   ACTIVATE_ST,
   READ_ST,
   WRITE_ST,
   BURST_ST,
   PRECHARGE_ST,
   TERMINATE_ST
} state_t;

state_t state;

always @(posedge ck_t or negedge cke) begin
   if(!cke) begin
      state <= IDLE;
      burst_running <= 0;
      dq_oe  <= 0;
      dqs_oe <= 0;
      burst_count <= 0;
   end
end




// ============================================================================
// DDR DEVICE - PART 2 COMMAND EXECUTION ENGINE
// Append this code inside ddr_device.sv after FSM declarations
// ============================================================================

logic activate_cmd;
logic read_cmd;
logic write_cmd;
logic precharge_cmd;
logic bterm_cmd;
logic mrs_cmd;

always_comb begin
    activate_cmd  = (cmd == CMD_ACTIVE);
    read_cmd      = (cmd == CMD_READ);
    write_cmd     = (cmd == CMD_WRITE);
    precharge_cmd = (cmd == CMD_PRECHARGE);
    bterm_cmd     = (cmd == CMD_BTERM);
    mrs_cmd       = (cmd == CMD_MRS);
end

// --------------------------------------------------------------------------
// ACTIVE
// --------------------------------------------------------------------------
task automatic execute_activate;
begin
$display($time,"**************************INSIDE ACT RTL  =%0d",ba);
    if(bank[ba].active && ck_c)
        $error("ACTIVE issued to already open bank");

    if(bank[ba].trp_cnt != 0)
        $error("tRP violation");

    bank[ba].active   <= 1'b1;
    bank[ba].open_row <= addr;

    bank[ba].trcd_cnt <= tRCD;
    bank[ba].tras_cnt <= tRAS;


end
endtask

// --------------------------------------------------------------------------
// PRECHARGE BANK
// --------------------------------------------------------------------------
task automatic precharge_bank
(
    input logic [1:0] bank_id
);
begin

    if(bank[bank_id].tras_cnt != 0)
        $error("tRAS violation");

    if(bank[bank_id].twr_cnt != 0)
        $error("tWR violation");

    bank[bank_id].active  <= 1'b0;
    bank[bank_id].trp_cnt <= tRP;

end
endtask

// --------------------------------------------------------------------------
// PRECHARGE ALL
// --------------------------------------------------------------------------
task automatic precharge_all;

integer b;

begin

    for(b=0;b<4;b++) begin

        bank[b].active  <= 0;
        bank[b].trp_cnt <= tRP;

    end

end
endtask

// --------------------------------------------------------------------------
// MRS CONTROL
// --------------------------------------------------------------------------
always @(posedge ck_t) begin

    if(mrs_cmd)
        load_mrs <= 1'b1;
    else
        load_mrs <= 1'b0;

end

// --------------------------------------------------------------------------
// READ PIPELINE
// --------------------------------------------------------------------------
logic read_pipeline_valid [0:7];

logic [1:0]  read_bank_pipe [0:7];
logic [13:0] read_row_pipe  [0:7];
logic [col_width - 1:0]  read_col_pipe  [0:7];

integer p;

always @(posedge ck_t) begin

    for(p=7;p>0;p--) begin

        read_pipeline_valid[p]
            <= read_pipeline_valid[p-1];

        read_bank_pipe[p]
            <= read_bank_pipe[p-1];

        read_row_pipe[p]
            <= read_row_pipe[p-1];

        read_col_pipe[p]
            <= read_col_pipe[p-1];

    end

end

// --------------------------------------------------------------------------
// READ EXECUTION
// --------------------------------------------------------------------------
task automatic execute_read;
begin
//	write_burst <= 1'b0;

    check_trcd(ba);

    if(!bank[ba].active && ck_c)
        $error("READ on closed bank");

    read_pipeline_valid[0] <= 1'b1;

    read_bank_pipe[0] <= ba;

    read_row_pipe[0]
        <= bank[ba].open_row;

    read_col_pipe[0]
        <= addr[9:0];

    auto_precharge
        <= addr[10];

end
endtask

// --------------------------------------------------------------------------
// WRITE EXECUTION
// --------------------------------------------------------------------------
task automatic execute_write;
begin

$display($time,"**************************INSIDE WRT RTL BA=%0d",ba);
    check_trcd(ba);

    if(!bank[ba].active && ck_c)
        $error("WRITE on closed bank");

    active_bank <= ba;

    active_row
        <= bank[ba].open_row;

    active_col
        <= addr[9:0];

    burst_running <= 1'b1;

    write_burst <= 1'b1;

    burst_count <= 0;

    auto_precharge <= addr[10];
            
    	if(write_burst) 
            bank[active_bank].twr_cnt <= tWR;
end
endtask

// --------------------------------------------------------------------------
// BURST TERMINATE
// --------------------------------------------------------------------------
task automatic execute_bterm;
begin
    burst_running <= 0;

    read_burst  <= 0;
    write_burst <= 0;

    dq_oe  <= 0;
    dqs_oe <= 0;

end
endtask

// --------------------------------------------------------------------------
// AUTO PRECHARGE CONTROL
// --------------------------------------------------------------------------
logic auto_precharge_pending;
logic [1:0] auto_precharge_bank;

// --------------------------------------------------------------------------
// MAIN COMMAND PROCESSOR
// --------------------------------------------------------------------------
always @(posedge ck_t or posedge ck_c) begin

    if(cke) begin

        case(cmd)

            CMD_ACTIVE :
                execute_activate();

            CMD_PRECHARGE : begin

                if(addr[10])
                    precharge_all();
                else
                    precharge_bank(ba);

            end

            CMD_READ : begin

                execute_read();

                if(addr[10]) begin

                    auto_precharge_pending <= 1'b1;
                    auto_precharge_bank    <= ba;

                end

            end

            CMD_WRITE : begin

                execute_write();
		burst_count <= 4'b0;
                if(addr[10]) begin

                    auto_precharge_pending <= 1'b1;
                    auto_precharge_bank    <= ba;

                end

            end

            CMD_BTERM :
                execute_bterm();

            default :
                ;

        endcase

    end

end

// ============================================================================
// END OF PART-2
// ============================================================================



// ============================================================================
// DDR DEVICE - PART 3 DATA PATH / BURST ENGINE
// ============================================================================

// --------------------------------------------------------------------------
// Burst Address Generator
// --------------------------------------------------------------------------
logic [col_width - 1:0] current_col;

always_comb begin
    if(burst_interleaved)
        current_col = active_col ^ burst_count; // interleaving
    else
        current_col = active_col + burst_count; // sequential
end

// --------------------------------------------------------------------------
// Read Data Pipeline
// --------------------------------------------------------------------------
logic [data_width - 1:0] read_data_pipe [0:7];

always @(posedge ck_t) begin
    if(read_pipeline_valid[cas_latency]) begin
        read_data_pipe[0]
            <= mem
               [read_bank_pipe[cas_latency]]
               [read_row_pipe [cas_latency]]
               [read_col_pipe [cas_latency]];

        read_burst    <= 1'b1;
        active_bank   <= read_bank_pipe[cas_latency];
        active_row    <= read_row_pipe[cas_latency];
        active_col    <= read_col_pipe[cas_latency];
        burst_running <= 1'b1;
    end
end

// --------------------------------------------------------------------------
// DDR READ OUTPUT WITH DQS GENERATION
// --------------------------------------------------------------------------
always @(posedge ck_c or posedge ck_t) begin
    // Look ahead: Only fetch and increment if we haven't already hit the burst limit
    if (read_burst && burst_running && (burst_count < burst_limit)) begin
        dq_oe   <= 1'b1;
        dqs_oe  <= 1'b1;
        dqs_out <= ck_t; // DQS matches ck_t phase (HIGH on ck_t, LOW on ck_c)

        dq_out <= mem
                  [active_bank]
                  [active_row]
                  [current_col];

        burst_count <= burst_count + 1;
    end else if (!write_burst) begin
        // Turn off outputs immediately when the burst finishes
        dq_oe   <= 1'b0;
        dqs_oe  <= 1'b0;
        dqs_out <= 1'b0;
    end
end

// --------------------------------------------------------------------------
// DDR WRITE CAPTURE (DQS BASED)
// --------------------------------------------------------------------------
always @(posedge dqs or negedge dqs) begin
    if(write_burst && burst_running) begin
        if(!dm) begin
            mem
            [active_bank]
            [active_row]
            [current_col]
            <= dq_in;
        end
        burst_count <= burst_count + 1;
    end
end

// --------------------------------------------------------------------------
// Burst Completion
// --------------------------------------------------------------------------
always @(posedge ck_t or posedge ck_c) begin  
    if(burst_running) begin
        if(burst_count >= burst_limit) begin
            burst_running <= 1'b0;
            read_burst    <= 1'b0;
            write_burst   <= 1'b0;
            dq_oe         <= 1'b0;
            dqs_oe        <= 1'b0;
            burst_count   <= 1'b0;

            if(write_burst)
                bank[active_bank].twr_cnt <= tWR;
        end
    end
end

// --------------------------------------------------------------------------
// Auto Precharge Scheduler
// --------------------------------------------------------------------------
always @(posedge ck_t) begin
    if(auto_precharge_pending) begin
        if(!burst_running) begin
            $display("INSIDE AUTO PRECHARGE RTL tras_cnt %0d, twr_cnt %0d",bank[auto_precharge_bank].tras_cnt,bank[auto_precharge_bank].twr_cnt);
            if(bank[auto_precharge_bank].tras_cnt == 0 &&
               bank[auto_precharge_bank].twr_cnt  == 0) begin

                bank[auto_precharge_bank].active  <= 1'b0;
                bank[auto_precharge_bank].trp_cnt <= tRP;
                auto_precharge_pending            <= 1'b0;
            end
        end
    end
end

// --------------------------------------------------------------------------
// Read Pipeline Cleanup
// --------------------------------------------------------------------------
always @(posedge ck_t) begin
    read_pipeline_valid[0] <= 1'b0;
end

// --------------------------------------------------------------------------
// Optional Protocol Checks
// --------------------------------------------------------------------------
always @(posedge ck_t) begin
    if(read_burst && write_burst)
        $error("READ and WRITE burst active simultaneously");

    if(burst_running &&
       (burst_limit != 2) &&
       (burst_limit != 4) &&
       (burst_limit != 8))
        $error("Illegal burst length");
end
endmodule
