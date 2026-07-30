// =============================================================================
// Module Name:    DDR_interface
// =============================================================================

`include "../config/DDR_timingpar.sv"
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../config/DDR_defines.sv"

interface DDR_interface (
    input bit ck_t,
    input bit ck_c
);

    // CLOCK ENABLE SIGNAL
    logic cke;

    // COMMAND SIGNALS
    logic cs;
    logic ras;
    logic cas;
    logic we;

    // ADDRESS SIGNALS
    logic [1:0] ba;
    logic [`ADDR_WIDTH-1:0] addr;

    // DATA SIGNALS
    wire  [`DATA_WIDTH-1:0] dq;
    wire                    dqs;
    logic                   dm;

    // Extra signals
    logic                   dq_en;
    logic [`DATA_WIDTH-1:0] dq_en_data;
    logic                   dqs_en;
    logic                   dqs_en_data;
    bit                     first_mrs_seen;

    assign dq  = dq_en  ? dq_en_data  : 'hz;
    assign dqs = dqs_en ? dqs_en_data : 1'bz;

    // Driver Clocking Block - CK_T

    clocking ddr_drv_cb_t @(posedge ck_t);
        default input #0 output #0;

        output cke;
        output cs;
        output ras;
        output cas;
        output we;

        output ba;
        output addr;

        output dq_en;
        output dqs_en;
        output dq_en_data;
        output dqs_en_data;

        inout dq;
        inout dqs;

        output dm;
    endclocking

    // Driver Clocking Block - CK_C

    clocking ddr_drv_cb_c @(posedge ck_c);
        default input #0 output #0;

        output cke;
        output cs;
        output ras;
        output cas;
        output we;

        output ba;
        output addr;

        output dq_en;
        output dqs_en;
        output dq_en_data;
        output dqs_en_data;

        inout dq;
        inout dqs;

        output dm;
    endclocking

    // Monitor Clocking Block - CK_T

    clocking ddr_mon_cb_t @(posedge ck_t);
        default input #0 output #0;

        input cke;
        input cs;
        input ras;
        input cas;
        input we;

        input ba;
        input addr;

        input dq_en;
        input dqs_en;
        input dq_en_data;
        input dqs_en_data;

        input dq;
        input dqs;
        input dm;
    endclocking

    // Monitor Clocking Block - CK_C

    clocking ddr_mon_cb_c @(posedge ck_c);
        default input #0 output #0;

        input cke;
        input cs;
        input ras;
        input cas;
        input we;

        input ba;
        input addr;

        input dq_en;
        input dqs_en;
        input dq_en_data;
        input dqs_en_data;

        input dq;
        input dqs;
        input dm;
    endclocking

    // Modports

    modport DDR_DRV_MP_T (clocking ddr_drv_cb_t);
    modport DDR_DRV_MP_C (clocking ddr_drv_cb_c);
    modport DDR_MON_MP_T (clocking ddr_mon_cb_t);
    modport DDR_MON_MP_C (clocking ddr_mon_cb_c);

    // EMRS -> MRS

    property DDR_EMRS_MRS;
        @(posedge ck_t) disable iff (!cke)
        $rose(cs == 0 && ras == 0 && cas == 0 && we == 0 && ba == 2'b01)
        |-> !(cs == 0 && ras == 0 && cas == 0 && we == 0 && ba == 2'b00)[*`TMRD];
    endproperty

    assert property (DDR_EMRS_MRS)
        `uvm_info("EMRS_MRS","EMRS to MRS assertion is passed",UVM_LOW)
    else
        `uvm_error("EMRS_MRS","EMRS to MRS assertion is failed")

    // First MRS Tracking

    always @(posedge ck_t) begin
        if (!cke)
            first_mrs_seen <= 0;
        else if (!first_mrs_seen &&
                 cs == 0 && ras == 0 && cas == 0 &&
                 we == 0 && ba == 2'b00)
            first_mrs_seen <= 1;
    end

    // MRS -> PRE

    property DDR_MRS_PRE;
        @(posedge ck_t)
        disable iff (!cke)

        (!first_mrs_seen &&
         cs == 0 && ras == 0 &&
         cas == 0 && we == 0 &&
         ba == 2'b00)
        |->
        !(cs == 0 && ras == 0 && cas == 1 && we == 0)[*`TDLL];
    endproperty

    assert property (DDR_MRS_PRE)
        `uvm_info("MRS_PRE","MRS to PRE assertion is passed",UVM_LOW)
    else
        `uvm_error("MRS_PRE","MRS to PRE assertion is failed")

    // PRE -> AR

    property DDR_PRE_AR;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 1 && we == 0)
        |-> !(cs == 0 && ras == 0 && cas == 0 && we == 1)[*`TRP];
    endproperty

    assert property (DDR_PRE_AR)
        `uvm_info("PRE_AR","PRE to AR assertion is passed",UVM_LOW)
    else
        `uvm_error("PRE to AR","PRE to AR assertion is failed")

    // AR -> MRS

    property DDR_AR_MRS;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 0 && we == 1)
        |-> !(cs == 0 && ras == 0 && cas == 0 && we == 0 && ba == 2'b00)[*`TRFC];
    endproperty

    assert property (DDR_AR_MRS)
        `uvm_info("AR_MRS","AR to MRS assertion is passed",UVM_LOW)
    else
        `uvm_error("AR to MRS","AR to MRS assertion is failed")

    
    // MRS -> ACT

    property DDR_MRS_ACT;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 0 && we == 0)
        |-> !(cs == 0 && ras == 0 && cas == 1 && we == 1)[*`TMRD];
    endproperty

    assert property (DDR_MRS_ACT)
        `uvm_info("MRS_ACT","MRS to ACT assertion passed",UVM_LOW)
    else
        `uvm_error("MRS to ACT","MRS to ACT assertion failed")

    // AR -> AR

    property DDR_AR_AR;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 0 && we == 1)
        |-> (cs == 0 && ras == 0 && cas == 0 && we == 1)[*`TRFC];
    endproperty

    assert property (DDR_AR_AR)
        `uvm_info("AR_AR","AR-AR assertion is passed",UVM_LOW)
    else
        `uvm_error("AR-AR","AR-AR assertion is failed")

    // ACT -> WRITE

    property DDR_act_to_write;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 1 && we == 1)
        |-> !(cs == 0 && ras == 1 && cas == 0 && we == 0) ||
             (cs == 0 && ras == 1 && cas == 0 && we == 1)[*`TRCD];
    endproperty

    assert property (DDR_act_to_write)
        `uvm_info("act_wr","act to wr assertion is passed",UVM_LOW)
    else
        `uvm_error("act_wr","act to wr assertion is failed")

    // WRITE -> DATA

    property DDR_write_to_data;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 1 && cas == 0 && we == 0)
        |-> (dq !== 'hz)[*`TDQSS];
    endproperty

    assert property (DDR_write_to_data)
        `uvm_info("wr_data","wr to data assertion is passed",UVM_LOW)
    else
        `uvm_error("wr_data","wr to data assertion is failed")

    // READ -> DATA

    property DDR_read_to_data;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 1 && cas == 0 && we == 1)
        |-> (dq !== 'hz)[*`TCL];
    endproperty

    assert property (DDR_read_to_data)
        `uvm_info("rd_data","rd to data assertion is passed",UVM_LOW)
    else
        `uvm_error("rd_data","rd to data assertion is failed")

    // WRITE -> READ

    property DDR_write_to_read;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 1 && cas == 0 && we == 0)
        |-> !(cs == 0 && ras == 1 && cas == 0 && we == 1)[*`TWTR];
    endproperty

    assert property (DDR_write_to_read)
        `uvm_info("wt_rd","write to read assertion is passed",UVM_LOW)
    else
        `uvm_error("write_read","write to read assertion is failed")

    // AR -> ACT

    property DDR_ar_to_act;
        @(posedge ck_t) disable iff(!cke)
        $rose(cs == 0 && ras == 0 && cas == 0 && we == 1)
        |-> !(cs == 0 && ras == 0 && cas == 1 && we == 1)[*`TRFC];
    endproperty

    assert property (DDR_ar_to_act)
        `uvm_info("ar_act","ar to act assertion is passed",UVM_LOW)
    else
        `uvm_error("ar_act","ar to act assertion is failed")

    // Clock Frequency Check

    property DDR_clockfrequency;
        time t1;

        @(posedge ck_t)
        (1, t1 = $time) |=> ($time - t1 == 10ns);
    endproperty

    assert property (DDR_clockfrequency)
        // `uvm_info("clk freq","DDR clock frequency assertion is passed",UVM_LOW)
    else
        `uvm_error("ASS clk fre","DDR clock frequency assertion is failed")

endinterface 
