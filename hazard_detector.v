`include "define.vh"
module hazard_detector(
    input wire [4:0] dstregpreRR,
    input wire [4:0] srcreg1_num,
    input wire [4:0] srcreg2_num,
    input wire is_loadpreRR,
    output wire is_stall
);

assign is_stall = (is_loadpreRR && ((srcreg1_num == dstregpreRR) || (srcreg2_num == dstregpreRR))) ? `ENABLE : `DISABLE;

endmodule