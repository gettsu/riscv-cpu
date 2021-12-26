`include "define.vh"
module RR(
    input wire clk,
    input wire rst,
    input wire [4:0] dstregpreRR1, dstregpreRR2,
    input wire [31:0] preRRpc1, preRRpc2,
    input wire [5:0] alucodepreRR1, alucodepreRR2,
    input wire [1:0] aluop1_typepreRR1, aluop2_typepreRR1,
    input wire [1:0] aluop1_typepreRR2, aluop2_typepreRR2,
    input wire [4:0] w_addrRW1, w_addrRW2,
    input wire [31:0] wb_dataRW1, wb_dataRW2,
    input wire [31:0] immpreRR1, immpreRR2,
    input wire reg_wepreRR1, is_loadpreRR1, is_storepreRR1,
    input wire reg_wepreRR2, is_loadpreRR2, is_storepreRR2,
    input wire wb_enRW1, wb_enRW2,
    input wire [2:0] funct3preRR1, funct3preRR2,
    input wire [4:0] srcreg11, srcreg12, srcreg21, srcreg22,
    input wire fail,     // 分岐予測失敗
    input wire [31:0] prePC1, prePC2,
    input wire [6:0] opcodepreRR1, opcodepreRR2,
    output wire [31:0] r_data1RR1, r_data2RR1, r_data1RR2, r_data2RR2,
    output reg [4:0] dstregRR1, dstregRR2,
    output reg [31:0] immRR1, immRR2,
    output reg [5:0] alucodeRR1, alucodeRR2,
    output reg [1:0] aluop1_typeRR1, aluop2_typeRR1, aluop1_typeRR2, aluop2_typeRR2,
    output reg reg_weRR1, reg_weRR2, is_loadRR1, is_loadRR2, is_storeRR1, is_storeRR2,
    output reg [31:0] RRpc1, RRpc2,
    output reg [2:0] funct3RR1, funct3RR2,
    output reg [4:0] srcreg11RR, srcreg12RR, srcreg21RR, srcreg22RR,
    output reg [31:0] prePCRR1, prePCRR2,
    output reg [6:0] opcodeRR1, opcodeRR2
);

wire we1, we2;
assign we1 = (w_addrRW1 == 5'd0) ? 1'd0 : (w_addrRW1 == w_addrRW2) ? 1'd0 : wb_enRW1;
assign we2 = (w_addrRW2 == 5'd0) ? 1'd0 : wb_enRW2;

regfile regfile0(
    .clk(clk),
    .we1(we1),
    .we2(we2),
    .r_addr11(srcreg11RR),
    .r_addr12(srcreg12RR),
    .r_addr21(srcreg21RR),
    .r_addr22(srcreg22RR),
    .w_addr1(w_addrRW1),
    .w_addr2(w_addrRW2),
    .r_data11(r_data1RR1),
    .r_data12(r_data2RR1),
    .r_data21(r_data1RR2),
    .r_data22(r_data2RR2),
    .w_data1(wb_dataRW1),
    .w_data2(wb_dataRW2)
);

always@ (posedge clk or negedge rst) begin
    if (!rst) begin
        dstregRR1 <= 5'd0;
        dstregRR2 <= 5'd0;
        immRR1 <= 32'd0;
        immRR2 <= 32'd0;
        alucodeRR1 <= `ALU_NOP;
        alucodeRR2 <= `ALU_NOP;
        aluop1_typeRR1 <= `OP_TYPE_NONE;
        aluop2_typeRR1 <= `OP_TYPE_NONE;
        aluop1_typeRR2 <= `OP_TYPE_NONE;
        aluop2_typeRR2 <= `OP_TYPE_NONE;
        reg_weRR1 <= `DISABLE;
        reg_weRR2 <= `DISABLE;
        is_loadRR1 <= `DISABLE;
        is_loadRR2 <= `DISABLE;
        is_storeRR1 <= `DISABLE;
        is_storeRR2 <= `DISABLE;
        RRpc1 <= 32'd0;
        RRpc2 <= 32'd0;
        funct3RR1 <= 3'd0;
        funct3RR2 <= 3'd0;
        srcreg11RR <= 5'd0;
        srcreg12RR <= 5'd0;
        srcreg21RR <= 5'd0;
        srcreg22RR <= 5'd0;
        opcodeRR1 <= 7'd0;
        opcodeRR2 <= 7'd0;
        prePCRR1 <= 32'd0;
        prePCRR2 <= 32'd0;
    end
    else if (fail) begin
        dstregRR1 <= 5'd0;
        dstregRR2 <= 5'd0;
        immRR1 <= 32'd0;
        immRR2 <= 32'd0;
        alucodeRR1 <= `ALU_NOP;
        alucodeRR2 <= `ALU_NOP;
        aluop1_typeRR1 <= `OP_TYPE_NONE;
        aluop2_typeRR1 <= `OP_TYPE_NONE;
        aluop1_typeRR2 <= `OP_TYPE_NONE;
        aluop2_typeRR2 <= `OP_TYPE_NONE;
        reg_weRR1 <= `DISABLE;
        reg_weRR2 <= `DISABLE;
        is_loadRR1 <= `DISABLE;
        is_loadRR2 <= `DISABLE;
        is_storeRR1 <= `DISABLE;
        is_storeRR2 <= `DISABLE;
        RRpc1 <= 32'd0;
        RRpc2 <= 32'd0;
        funct3RR1 <= 3'd0;
        funct3RR2 <= 3'd0;
        srcreg11RR <= 5'd0;
        srcreg12RR <= 5'd0;
        srcreg21RR <= 5'd0;
        srcreg22RR <= 5'd0;
        opcodeRR1 <= 7'd0;
        opcodeRR2 <= 7'd0;
        prePCRR1 <= 32'd0;
        prePCRR2 <= 32'd0;
    end
    else begin
        dstregRR1 <= dstregpreRR1;
        dstregRR2 <= dstregpreRR2;
        immRR1 <= immpreRR1;
        immRR2 <= immpreRR2;
        alucodeRR1 <= alucodepreRR1;
        alucodeRR2 <= alucodepreRR2;
        aluop1_typeRR1 <= aluop1_typepreRR1;
        aluop2_typeRR1 <= aluop2_typepreRR1;
        aluop1_typeRR2 <= aluop1_typepreRR2;
        aluop2_typeRR2 <= aluop2_typepreRR2;
        reg_weRR1 <= reg_wepreRR1;
        reg_weRR2 <= reg_wepreRR2;
        is_loadRR1 <= is_loadpreRR1;
        is_loadRR2 <= is_loadpreRR2;
        is_storeRR1 <= is_storepreRR1;
        is_storeRR2 <= is_storepreRR2;
        RRpc1 <= preRRpc1;
        RRpc2 <= preRRpc2;
        funct3RR1 <= funct3preRR1;
        funct3RR2 <= funct3preRR2;
        srcreg11RR <= srcreg11;
        srcreg12RR <= srcreg12;
        srcreg21RR <= srcreg21;
        srcreg22RR <= srcreg22;
        opcodeRR1 <= opcodepreRR1;
        opcodeRR2 <= opcodepreRR2;
        prePCRR1 <= prePC1;
        prePCRR2 <= prePC2;
    end
end
endmodule