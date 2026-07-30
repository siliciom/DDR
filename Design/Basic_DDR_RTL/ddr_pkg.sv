package ddr_pkg;

parameter int BANKS      = 4;
parameter int ROWS       = 16384;
parameter int COLS       = 1024;

parameter int ROW_BITS   = 14;
parameter int COL_BITS   = 10;
parameter int BANK_BITS  = 2;

parameter int CL    = 2;
parameter int tRCD  = 2;
parameter int tRP   = 2;
parameter int tRAS  = 5;
parameter int tWR   = 2;
parameter int tRFC  = 7;

typedef enum logic [3:0] {
    CMD_NOP,
    CMD_ACTIVE,
    CMD_READ,
    CMD_WRITE,
    CMD_PRECHARGE,
    CMD_MRS,
    CMD_BTERM,
    CMD_DESELECT
} cmd_t;

typedef enum logic [1:0] {
    BL2 = 2'd0,
    BL4 = 2'd1,
    BL8 = 2'd2
} burst_length_t;

typedef struct packed {
    logic active;
    logic [ROW_BITS-1:0] open_row;

    logic auto_precharge;

    logic [7:0] trcd_cnt;
    logic [7:0] tras_cnt;
    logic [7:0] trp_cnt;
    logic [7:0] twr_cnt;

} bank_state_t;

endpackage
