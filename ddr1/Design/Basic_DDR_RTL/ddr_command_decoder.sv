import ddr_pkg::*;
module ddr_command_decoder
(
    input  logic cs_n,
    input  logic ras_n,
    input  logic cas_n,
    input  logic we_n,

    output cmd_t cmd
);


always_comb begin

    cmd = CMD_NOP;

    if(cs_n)
        cmd = CMD_DESELECT;

    else begin

        case({ras_n,cas_n,we_n})

            3'b111 : cmd = CMD_NOP;
            3'b011 : cmd = CMD_ACTIVE;
            3'b101 : cmd = CMD_READ;
            3'b100 : cmd = CMD_WRITE;
            3'b010 : cmd = CMD_PRECHARGE;
            3'b000 : cmd = CMD_MRS;
            3'b110 : cmd = CMD_BTERM;
            default : cmd = CMD_NOP;

        endcase
//$display($time,"Command detected in ddr_COMMAND_RTL cmd %s",cmd);
    end
end

endmodule
