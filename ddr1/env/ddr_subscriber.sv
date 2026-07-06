// ============================================================================
// Component       : DDR_coverage
// ============================================================================

class DDR_cov extends uvm_subscriber #(DDR_seq_item);
    
    `uvm_component_utils(DDR_cov)
    
    // Handle for the sampled transaction packet
    DDR_seq_item seq;

    // ========================================================================
    // COVERGROUP DEFINITION
    // ========================================================================
    covergroup ddr_cg;
        
        // Coverpoint for DDR Command Types
        cmd_cp: coverpoint seq.cmd {
            bins ACT       = {ACTIVATE};
            bins WRITE     = {WRITE};
            bins READ      = {READ};
            bins PRECHARGE = {PRECHARGE};
            bins MRS       = {MRS};
            bins BST       = {BST};
        }

        // Coverpoint for Burst Length configurations
        burst_cp : coverpoint seq.cfg_bl {
            bins BL2 = {2};
            bins BL4 = {4};
            bins BL8 = {8};
        }

        // Coverpoint for CAS Latency configurations
        cas_latency_cp : coverpoint seq.cfg_cl {
            bins ca1 = {3'b010};
            ignore_bins CL_ignore[] = {[3:7]};
        }

        // Coverpoint for Burst Type (Sequential vs Interleaved)
        burst_type_cp : coverpoint seq.cfg_bt {
            bins seq   = {0};
            bins intlv = {1};
        }

        // Coverpoint splitting 16-bit DQ data values into 4 uniform ranges
        dq_cp : coverpoint seq.dq {
            bins dq_low  = {[0:16383]};
            bins dq_low1 = {[16384:32767]};
            bins dq_med  = {[32768:49151]};
            bins dq_high = {[49152:65535]};
        }

        // Coverpoint checking if Data Mask (DM) is asserted
        dm_cp : coverpoint seq.dm {
            bins masked   = {1};
            bins unmasked = {0};
        }

        // Coverpoint verifying Auto-Precharge selection during Read/Write commands
        addr_ap_cp : coverpoint seq.addr[10] iff(seq.cmd inside {READ, WRITE}) {
            bins auto_precharge = {1};
            bins normal         = {0};
        }

        // Coverpoint checking Precharge scope (Single Bank vs All Banks)
        addr_p_cp : coverpoint seq.addr[10] iff(seq.cmd == PRECHARGE) {
            bins all_bank = {1};
            bins one_bank = {0};
        }

        // General Address map mapping space into 4 auto-calculated bins
        addr_cp : coverpoint seq.addr {
            option.auto_bin_max = 4;
        }

        // Coverpoint tracking structural Bank distribution
        ba_cp: coverpoint seq.ba {
            bins ba_bins[] = {[0:3]};
        }

	sequences:coverpoint seq.cmd{
	bins act_wri[]=(ACTIVATE => WRITE);
	bins wri_re[]=(WRITE => READ);
	bins compl_flw[]=(ACTIVATE => WRITE => READ => PRECHARGE);
 
	}
        // --------------------------------------------------------------------
        // CROSS COVERAGE
        // --------------------------------------------------------------------
        
        // Cross between Command and Bank Selection
        cmd_ba_cross : cross cmd_cp, ba_cp {
            // MRS cycle can only target Bank 0 (ignore BA[1:3] during MRS)
            ignore_bins mrs_ba123 = binsof(cmd_cp) intersect {MRS} && 
                                    binsof(ba_cp) intersect {[1:3]};
        }

        // Cross between Command Type and Burst Length configurations
        cmd_bl_cross : cross cmd_cp, burst_cp {
            // Burst Terminate is not applicable or valid for a short BL2 run
            ignore_bins bst_bl2 = binsof(cmd_cp) intersect {BST} && binsof(burst_cp.BL2);    
            // Precharge command configurations do not depend on ongoing Burst Lengths
            ignore_bins pre_bl  = binsof(cmd_cp) intersect {PRECHARGE} && binsof(burst_cp);
        }    

        // Cross between targeting Bank and the respective memory Address boundary
        ba_addr_cross : cross ba_cp, addr_cp;

    endgroup

    // ========================================================================
    // COMPONENT METHODS
    // ========================================================================

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ddr_cg = new();
    endfunction

    // Standard UVM subscriber write method interface
    function void write(DDR_seq_item t);
        seq = t;
        
        `uvm_info("COV", $sformatf("DM = %0d", seq.dm), UVM_LOW)
        
        // Loops through each beat inside the packet burst array to update the data path coverage variable
        foreach (seq.dq_burst[i]) begin
            `uvm_info("COV_DEBUG", $sformatf("Burst Beat [%0d] DQ Value : %0d", i, seq.dq_burst[i]), UVM_LOW)
            seq.dq = seq.dq_burst[i]; 
        end
    
        // Samples the transaction packet attributes into the coverage metrics engine
        ddr_cg.sample();
    endfunction

endclass
