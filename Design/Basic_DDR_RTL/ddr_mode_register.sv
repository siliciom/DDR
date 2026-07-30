module ddr_mode_register
(
    input logic clk,
    input logic rst_n,

    input logic load,
    input logic [13:0] addr,

    output ddr_pkg::burst_length_t burst_length,
    output logic burst_interleaved,
    output logic [2:0] cas_latency
);

import ddr_pkg::*;

burst_length_t bl_reg;

assign burst_length = bl_reg;

always_ff @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        bl_reg             <= BL4;
        burst_interleaved  <= 1'b0;
        cas_latency        <= 3'd2;

    end
    else if(load) begin


$display("CFG BL IN RTL %0b",addr[2:0]);
        case(addr[2:0])
   
       	    3'b001 : bl_reg <= BL2;
            3'b010 : bl_reg <= BL4;
            3'b011 : bl_reg <= BL8;

            default: bl_reg <= BL4;

        endcase

        burst_interleaved <= addr[3];
        cas_latency       <= addr[6:4];

    end
end

endmodule
