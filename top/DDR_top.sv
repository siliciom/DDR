// =============================================================================
// Module Name:    DDR_TOP
// =============================================================================

`timescale 1ns/1ps

`include "../config/DDR_defines.sv"
`include "../config/DDR_timingpar.sv"
`include "DDR_interface.sv"

module DDR_top;

    import uvm_pkg::*;
    import DDR_pkg::*;

    // Clock Generation

    reg ck_t = 0;
    reg ck_c = 1;

    always #`TCK2 ck_t = ~ck_t;
    always #`TCK2 ck_c = ~ck_c;

    // Interface

    DDR_interface vif(ck_t, ck_c);

    // DUT Instantiation

    ddr_device #(
        .addr_width (`ADDR_WIDTH),
        .data_width (`DATA_WIDTH),
        .col_width  (`COL_WIDTH)
    ) DUT (
        .ck_t   (vif.ck_t),
        .ck_c   (vif.ck_c),

        .cke    (vif.cke),
        .cs_n   (vif.cs),
        .ras_n  (vif.ras),
        .cas_n  (vif.cas),
        .we_n   (vif.we),

        .ba     (vif.ba),
        .addr   (vif.addr),

        .dq     (vif.dq),
        .dqs    (vif.dqs),
        .dm     (vif.dm)
    );

    // UVM Start

    initial begin
        uvm_config_db#(virtual DDR_interface)::set(null,"*","DDR_interface",vif);

        run_test();
    end

    // DDR Configuration Display

    initial begin
`ifdef DDR_X4
        $display("DDR_X4 defined");
`elsif DDR_X8
        $display("DDR_X8 defined");
`else
        $display("DDR MODE DEFINED");
`endif

        $display("MACRO DATA_WIDTH = %0d", `DATA_WIDTH);
        $display("DUT data_width   = %0d", DUT.data_width);
    end

    initial begin
        $display("\n=== DDR CONFIGURATION ===");
        $display("DATA_WIDTH = %0d", `DATA_WIDTH);
        $display("COL_WIDTH  = %0d", `COL_WIDTH);
        $display("ADDR_WIDTH = %0d", `ADDR_WIDTH);
        $display("==========================\n");
    end

    // Wave Dump

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DDR_top);
    end
    
   
endmodule : DDR_top 
