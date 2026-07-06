//=============================================================================
//
// Component Name : DDR_agent
// 
//=============================================================================

class DDR_agent extends uvm_agent;
  `uvm_component_utils(DDR_agent)
  
  //---------------------------------------------------------------------------
  // Component Handles
  //---------------------------------------------------------------------------
  DDR_driver    drvh;
  DDR_sequencer seqh;
  DDR_monitor   monh;
  
  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------
  function new (string name = "DDR_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  //---------------------------------------------------------------------------
  // Build Phase: Instantiate sub-components using the UVM factory
  //---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create monitor, driver, and sequencer instances
    monh = DDR_monitor::type_id::create("monh", this);
    drvh = DDR_driver::type_id::create("drvh", this);
    seqh = DDR_sequencer::type_id::create("seqh", this);
  endfunction : build_phase
  
  //---------------------------------------------------------------------------
  // Connect Phase: TLM connections between driver and sequencer
  //---------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect the driver's sequence item port to the sequencer's export
    drvh.seq_item_port.connect(seqh.seq_item_export);
  endfunction : connect_phase
  
endclass : DDR_agent
