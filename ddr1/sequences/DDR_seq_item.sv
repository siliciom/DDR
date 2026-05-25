typedef enum {ACTIVATE, READ, WRITE, PRECHARGE,MRS} rand_cmd;
class DDR_seq_item extends uvm_sequence_item;
 //`uvm_object_utils(DDR_seq_item) 
  rand rand_cmd cmd;
  rand bit cke;
  rand bit cs;
  rand bit ras;
  rand bit cas;
  rand bit we;
  rand bit [1:0] ba;
  rand bit [13:0]addr;
  rand bit [15:0]dq;
  rand bit dqs;
  rand bit dm;
  randc bit [15:0] dq_burst[8];
  rand bit [3:0] cfg_bl;
  rand bit cfg_bt;
  rand bit auto_precharge;

  constraint c1 { foreach(dq_burst[i])
  			dq_burst[i] inside {[30:500]};}

  constraint c2 {soft cfg_bl inside {2,4,8};}
 
  `uvm_object_utils_begin(DDR_seq_item)

  `uvm_field_enum(rand_cmd ,cmd, UVM_ALL_ON)
   `uvm_field_int(cs,UVM_ALL_ON)
   `uvm_field_int(ras, UVM_ALL_ON)
   `uvm_field_int(cas,  UVM_ALL_ON)
   `uvm_field_int(we, UVM_ALL_ON)
   `uvm_field_int(ba, UVM_ALL_ON)
   `uvm_field_int(addr, UVM_ALL_ON)
   `uvm_field_int(dq, UVM_ALL_ON)
   `uvm_field_int(dqs,UVM_ALL_ON)
 `uvm_object_utils_end  
  
  function new(string name ="DDR_seq_item");
    super.new(name);
  endfunction
  
endclass
    
