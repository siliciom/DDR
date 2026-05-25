`timescale 1ns/1ps // Data rate is 200
`define TRAS 50 //ACTIVEto precharge command
`define TRCD 20  //Activate to READ or WRITE command
`define TRC  70    //ACTIVE to ACTIVE/AutoRefresh commandperiod
`define TRRD 15   //ACTIVE bankA to ACTIVE bankB command
`define TDQSS 7.5 //Write command to first DQS latching transition
`define TWTR 10  //Internal Write to Read Command Delay
`define TWR 15 //Write recovery time
`define TRP 20 //PRECHARGE command period
`define TCK 10 // clock cycle time
`define TCL 2  //CAS latency
`define TMRD 20 // MODEREGISTER SET command cycle time
`define TRFC 80 // Auto refresh to Auto refresh and Auto refresh to Mode register
//`define TWR 15
`define TWPRE 2.5
`define TWPST 4
`define TCK4 2.5
`define TCK2 5
`define TDLL 200
