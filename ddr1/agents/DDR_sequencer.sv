class DDR_sequencer extends uvm_sequencer #(DDR_seq_item);
  
  `uvm_component_utils(DDR_sequencer)
  
  function new(string name ="DDR_sequencer",uvm_component parent=null);
    super.new(name,parent);
  endfunction
endclass