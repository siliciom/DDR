//==============================================================================
// Component Name : ddr_mul_wr_intlv_bl8_100_X4_test
// Type           : UVM Test
// Test Owner     : Anitha
//==============================================================================

class ddr_mul_wr_intlv_bl8_100_X4_test extends uvm_test;

  `uvm_component_utils(ddr_mul_wr_intlv_bl8_100_X4_test)

  DDR_env envh;
  ddr_mul_wr_intlv_bl8_100_X4_seq wr_mul_seqh;

  function new(string name = "ddr_mul_wr_intlv_bl8_100_X4_test",uvm_component parent );
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    envh = DDR_env::type_id::create("envh", this);
  endfunction

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    wr_mul_seqh = ddr_mul_wr_intlv_bl8_100_X4_seq::type_id::create("wr_mul_seqh");

    wr_mul_seqh.start(envh.agt.seqh);

    #150;

    phase.drop_objection(this);

  endtask

endclass

