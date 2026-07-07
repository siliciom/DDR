//==============================================================================
// Component Name : DDR_timingpar
// Description    : Defines the timing parameters and constant constraints
//                  for the DDR memory interface simulation.
//==============================================================================
`timescale 1ns/1ps
    
`define TRAS 5 //ACTIVEto precharge command
`define TRCD 2  //Activate to READ or WRITE command
`define TRC  7    //ACTIVE to ACTIVE/AutoRefresh commandperiod
`define TRRD 2   //ACTIVE bankA to ACTIVE bankB command
`define TDQSS 1 //Write command to first DQS latching transition
`define TWTR 1  //Internal Write to Read Command Delay
`define TWR 2 //Write recovery time
`define TRP 2 //PRECHARGE command period
`define TCK 1 // clock cycle time
`define TCL 2  //CAS latency
`define TMRD 2 // MODEREGISTER SET command cycle time
`define TRFC 8 // Auto refresh to Auto refresh and Auto refresh to Mode register
`define TWPRE 2.5
`define TWPST 4
`define TCK4 2.5
`define TCK2 5
`define TDLL 200

 
`ifdef INJECTING_TIMING_ERROR

`define TRAS_DRV 1 //ACTIVEto precharge command
`define TRCD_DRV 0  //Activate to READ or WRITE command
`define TRC_DRV  3    //ACTIVE to ACTIVE/AutoRefresh commandperiod
`define TRRD_DRV 0   //ACTIVE bankA to ACTIVE bankB command
`define TDQSS_DRV 0 //Write command to first DQS latching transition
`define TWTR_DRV 1  //Internal Write to Read Command Delay
`define TWR_DRV 1 //Write recovery time
`define TRP_DRV 1 //PRECHARGE command period
`define TCK_DRV 0 // clock cycle time
`define TCL_DRV 0  //CAS latency
`define TMRD_DRV 1 // MODEREGISTER SET command cycle time
`define TRFC_DRV 4 // Auto refresh to Auto refresh and Auto refresh to Mode register
`define TWPRE_DRV 1
`define TWPST_DRV 2
`define TCK4_DRV 2
`define TCK2_DRV 2
`define TDLL_DRV 200
 
`else
`define TRAS_DRV `TRAS //ACTIVEto precharge command
`define TRCD_DRV `TRCD //Activate to READ or WRITE command
`define TRC_DRV  `TRC    //ACTIVE to ACTIVE/AutoRefresh commandperiod
`define TRRD_DRV `TRRD   //ACTIVE bankA to ACTIVE bankB command
`define TDQSS_DRV `TDQSS //Write command to first DQS latching transition
`define TWTR_DRV `TWTR  //Internal Write to Read Command Delay
`define TWR_DRV `TWR //Write recovery time
`define TRP_DRV `TRP //PRECHARGE command period
`define TCK_DRV `TCK // clock cycle time
`define TCL_DRV `TCL  //CAS latency
`define TMRD_DRV `TMRD // MODEREGISTER SET command cycle time
`define TRFC_DRV `TRFC // Auto refresh to Auto refresh and Auto refresh to Mode register
`define TWPRE_DRV `TWPRE
`define TWPST_DRV `TWPST
`define TCK4_DRV `TCK4
`define TCK2_DRV `TCK2
`define TDLL_DRV `TDLL

`endif

//`define INJECTING_TIMING_ERROR

