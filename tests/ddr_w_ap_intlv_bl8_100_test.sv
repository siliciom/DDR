//==============================================================================
// Component Name : ddr_w_ap_intlv_bl8_100_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_w_ap_intlv_bl8_100_test extends DDR_test;

  `uvm_component_utils(ddr_w_ap_intlv_bl8_100_test)

  ddr_w_ap_intlv_bl8_100_seq w_ap_seqh;

  function new(
    string name = "ddr_w_ap_intlv_bl8_100_test",
    uvm_component parent
  );
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    w_ap_seqh =
      ddr_w_ap_intlv_bl8_100_seq::type_id::create("w_ap_seqh");

    w_ap_seqh.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass


