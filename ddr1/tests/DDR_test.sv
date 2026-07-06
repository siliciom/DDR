//==============================================================================
// Component Name : DDR_test
// Description    : UVM-based test designed to print the complete UVM hierarchy/topology.
//==============================================================================

class DDR_test extends uvm_test;
  `uvm_component_utils(DDR_test)
  
  DDR_env envh;
  virtual DDR_interface vif;

  // Constructor
  function new(string name="DDR_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Get interface from top TB
    if (!uvm_config_db #(virtual DDR_interface)::get(this, "", "DDR_interface", vif))
      `uvm_fatal("TEST", "Did not get vif")

    // Set interface for all lower-level components (driver + monitor)
    uvm_config_db #(virtual DDR_interface)::set(this, "*", "DDR_interface", vif);
    
    // Create environment structure
    envh = DDR_env::type_id::create("envh", this);
  endfunction

  // End of Elaboration Phase
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
