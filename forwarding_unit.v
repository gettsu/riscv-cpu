`include "define.vh"
module forwarding_unit(
    input wire [4:0] dstregEX1, dstregEX2,
    input wire [4:0] dstregMA1, dstregMA2,
    input wire [4:0] srcreg11_num,
    input wire [4:0] srcreg12_num,
    input wire [4:0] srcreg21_num,
    input wire [4:0] srcreg22_num,
    input wire reg_weEX1, reg_weEX2,
    input wire reg_weMA1, reg_weMA2,
    output wire [2:0] forwarding11,
    output wire [2:0] forwarding12,
    output wire [2:0] forwarding21,
    output wire [2:0] forwarding22
);

function [2:0] forward;
    input [4:0] dstregEX1, dstregEX2;
    input [4:0] dstregMA1, dstregMA2;
    input [4:0] srcreg;
    input reg_weEX1, reg_weEX2, reg_weMA1, reg_weMA2;
    if (reg_weEX2 && (dstregEX2 != 5'd0) && (srcreg == dstregEX2)) begin
        forward = 3'd4;
    end
    else if (reg_weEX1 && (dstregEX1 != 5'd0) && (srcreg == dstregEX1)) begin
        forward = 3'd2;
    end
    else if (reg_weMA2 && (dstregMA2 != 5'd0) && (srcreg == dstregMA2)) begin
        forward = 3'd3;
    end
    else if (reg_weMA1 && (dstregMA1 != 5'd0) && (srcreg == dstregMA1)) begin
        forward = 3'd1;
    end
    else begin
        forward = 3'd0;
    end
endfunction

assign forwarding11 = forward(dstregEX1, dstregEX2, dstregMA1, dstregMA2, srcreg11_num, reg_weEX1, reg_weEX2, reg_weMA1, reg_weMA2);
assign forwarding12 = forward(dstregEX1, dstregEX2, dstregMA1, dstregMA2, srcreg12_num, reg_weEX1, reg_weEX2, reg_weMA1, reg_weMA2);
assign forwarding21 = forward(dstregEX1, dstregEX2, dstregMA1, dstregMA2, srcreg21_num, reg_weEX1, reg_weEX2, reg_weMA1, reg_weMA2);
assign forwarding22 = forward(dstregEX1, dstregEX2, dstregMA1, dstregMA2, srcreg22_num, reg_weEX1, reg_weEX2, reg_weMA1, reg_weMA2);

endmodule


