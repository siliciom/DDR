// =============================================================================
// Module Name:    DDR_sequence_item
// =============================================================================

typedef enum {
    IDLE,
    MRS,
    NOP,
    ACTIVATE,
    WRITE,
    READ,
    PRECHARGE,
    BST
} rand_cmd;

class DDR_seq_item extends uvm_sequence_item;

    // Command and Control Signals
    rand rand_cmd cmd;
    rand bit      cke;
    rand bit      cs;
    rand bit      ras;
    rand bit      cas;
    rand bit      we;

    // Address Signals
    rand bit [1:0]               ba;
    rand bit [`ADDR_WIDTH-1:0]   addr;

    // Data Signals
    rand bit [`DATA_WIDTH-1:0]   dq;
    rand bit                     dqs;
    rand bit                     dm;

    // Burst Data
    rand reg [`DATA_WIDTH-1:0]   dq_burst[8];

    // Configuration Parameters
    rand bit [3:0]               cfg_bl;
    rand bit [3:0]               cfg_cl;
    rand bit                     cfg_interleave;
    rand bit                     bst_mode;

    // Data Mask Information
    int                          dm_array[$];
    int                          dm_mode;

    // Control Flags
    bit                          do_power_down;
    rand bit                     cfg_bt;
    rand bit                     auto_precharge;
    rand bit                     precharge_all;

    // Status Flags
    bit                          bst_detected;
    int                          burst_beats_received;

    // Constraints

 //   constraint c1 {
   //     foreach (dq_burst[i])
    //        dq_burst[i] inside {[0:10000]};
   // }

    constraint c2 {
        soft cfg_bl inside {2, 4, 8};
    }

    constraint c3 {
        soft bst_mode == 0;
    }


    // Factory Registration

    `uvm_object_utils_begin(DDR_seq_item)

        `uvm_field_enum(rand_cmd, cmd, UVM_ALL_ON)

        `uvm_field_int(cs,   UVM_ALL_ON)
        `uvm_field_int(ras,  UVM_ALL_ON)
        `uvm_field_int(cas,  UVM_ALL_ON)
        `uvm_field_int(we,   UVM_ALL_ON)
        `uvm_field_int(ba,   UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(dq,   UVM_ALL_ON)
        `uvm_field_int(dqs,  UVM_ALL_ON)

    `uvm_object_utils_end

    // Constructor

    function new(string name = "DDR_seq_item");
        super.new(name);
    endfunction

endclass : DDR_seq_item
    
