class DDR_agent extends uvm_agent;
  `uvm_component_utils(DDR_agent)
  
  DDR_driver drvh;
  DDR_sequencer seqh;
  DDR_monitor monh;
  
  function new (string name = "DDR_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
   
    super.build_phase(phase);
    monh   = DDR_monitor::type_id::create("monh",this);
    drvh   = DDR_driver::type_id::create("drvh",this);
    seqh = DDR_sequencer::type_id::create("seqh",this);
 
  endfunction
  
 function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
   drvh.seq_item_port.connect(seqh.seq_item_export);
     
  endfunction
  
endclass

