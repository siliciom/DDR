`timescale 1ns/1ps
//`include "TOP_MODULE_DDR_SDRAM.v"
`include "../top/DDR_interface.sv"
`include "../config/DDR_timingpar.sv"
module DDR_top;

 	import uvm_pkg::*;
	import DDR_pkg::*;



    reg ck_t=0;
    reg ck_c=1;
    always #`TCK2 ck_t = ~ck_t;
    always #`TCK2 ck_c = ~ck_c;
  
   DDR_interface vif(ck_t,ck_c);
  
 // DDR_interface vif(ck_t);
//   ddr dut(
//     .CK(vif.ck_t),
//     .CK_N(vif.ck_c),
//     .CKE(vif.cke),
//     .CS_N(vif.cs),
//     .RAS_N(vif.ras),
//     .CAS_N(vif.cas),
//     .WE_N(vif.cas),
//     .(vif.ba),
//     .addr(vif.addr),
//     .(vif.dq),
//     .dqs_o(vif.dqs_o),
//     .dqs_i(vif.dqs_i)
//     .dm(vif.dm),
//   );
  initial begin
   
    uvm_config_db #(virtual DDR_interface)::set(null,"*","DDR_interface",vif);

    //Start UVM_test
    run_test();
  end
  
  initial begin
   $dumpfile("dump.vcd"); 
   $dumpvars(0,DDR_top);
   end
  
endmodule

  
          
    
  
