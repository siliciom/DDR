// =============================================================================
// Module Name:    DDR_Environment
// =============================================================================
class DDR_env extends uvm_env;

    `uvm_component_utils(DDR_env)

    DDR_agent      agt;
    DDR_scoreboard scrb;
    DDR_cov        cov;

    function new(string name = "DDR_env",uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt  = DDR_agent::type_id::create("agt", this);
        scrb = DDR_scoreboard::type_id::create("scrb", this);
        cov  = DDR_cov::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agt.monh.mon_ap_write.connect(scrb.sb_port_w);
        agt.monh.mon_ap_read.connect(scrb.sb_port_r);

        agt.monh.mon_ap_write.connect(cov.analysis_export);
        agt.monh.mon_ap_read.connect(cov.analysis_export);
    endfunction

endclass : DDR_env  
