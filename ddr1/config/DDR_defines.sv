//==============================================================================
// Component Name : DDR_defines
// Description    : Configures the core memory data, column, and address widths 
//                  based on the targeted memory chip layout macro (`ifdef).
//==============================================================================

`ifdef DDR_X4
  `define DATA_WIDTH 4
  `define COL_WIDTH  12
  `define ADDR_WIDTH 14
`elsif DDR_X8
  `define DATA_WIDTH 8
  `define COL_WIDTH  11
  `define ADDR_WIDTH 14
`else
  // Default configuration (if no +define is given)
  `define DATA_WIDTH 16
  `define COL_WIDTH  10
  `define ADDR_WIDTH 14
`endif
