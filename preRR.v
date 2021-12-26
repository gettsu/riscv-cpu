`include "define.vh"
module preRR(
    input wire clk,
    input wire rst,
    input wire [31:0] ir1, ir2,
    input wire [31:0] IFpc1, IFpc2,
    input wire is_jump1, is_jump2,
    input wire fail,
    input wire [5:0] alucodeRR1, alucodeRR2,
    input wire [6:0] opcodeRR1, opcodeRR2,
    output reg [4:0] dstregpreRR1, dstregpreRR2,
    output reg [31:0] immpreRR1, immpreRR2,
    output reg [5:0] alucodepreRR1, alucodepreRR2,
    output reg [1:0] aluop1_typepreRR1, aluop2_typepreRR1,
    output reg [1:0] aluop1_typepreRR2, aluop2_typepreRR2,
    output reg reg_wepreRR1, is_loadpreRR1, is_storepreRR1,
    output reg reg_wepreRR2, is_loadpreRR2, is_storepreRR2,
    output reg [31:0] preRRpc1, preRRpc2,
    output reg [2:0] funct3preRR1, funct3preRR2,
    output reg  [4:0] srcreg11, srcreg12, srcreg21, srcreg22,
    output wire is_stall,
    output wire pre_branch1, pre_branch2,
    output wire [31:0] predict_pc1, predict_pc2,
    output reg [31:0] prePC1, prePC2,
    output reg [6:0] opcodepreRR1, opcodepreRR2,
    output wire depend    // ２と１に依存関係があるとストール
);
wire [4:0] srcreg11_num, srcreg12_num, dstreg1_num;
wire [4:0] srcreg21_num, srcreg22_num, dstreg2_num;
wire [31:0] imm_dpl1, imm_dpl2;
wire [5:0] alucode_reg1, alucode_reg2;
wire [1:0] aluop11, aluop12, aluop21, aluop22;
wire we1, load1, store1, halt1, we2, load2, store2, halt2;
wire [2:0] funct3_1, funct3_2;

wire [6:0] opcode_wire1, opcode_wire2;
assign opcode_wire1 = ir1[6:0];
assign opcode_wire2 = ir2[6:0];
wire is_stall0, is_stall1, is_stall2, is_stall3;

decoder decoder0(
    .ir(ir1),
    .srcreg1_num(srcreg11_num),
    .srcreg2_num(srcreg12_num),
    .dstreg_num(dstreg1_num),
    .imm(imm_dpl1),
    .alucode(alucode_reg1),
    .aluop1_type(aluop11),
    .aluop2_type(aluop12),
    .reg_we(we1),
    .is_load(load1),
    .is_store(store1),
    .is_halt(halt1),
    .funct3(funct3_1)
);

decoder decoder1(
    .ir(ir2),
    .srcreg1_num(srcreg21_num),
    .srcreg2_num(srcreg22_num),
    .dstreg_num(dstreg2_num),
    .imm(imm_dpl2),
    .alucode(alucode_reg2),
    .aluop1_type(aluop21),
    .aluop2_type(aluop22),
    .reg_we(we2),
    .is_load(load2),
    .is_store(store2),
    .is_halt(halt2),
    .funct3(funct3_2)
);

hazard_detector hazard_detector0(
    .dstregpreRR(dstregpreRR1),
    .srcreg1_num(srcreg11_num),
    .srcreg2_num(srcreg12_num),
    .is_loadpreRR(is_loadpreRR1),
    .is_stall(is_stall0)
);

hazard_detector hazard_detector1(
    .dstregpreRR(dstregpreRR1),
    .srcreg1_num(srcreg21_num),
    .srcreg2_num(srcreg22_num),
    .is_loadpreRR(is_loadpreRR1),
    .is_stall(is_stall1)
);

hazard_detector hazard_detector2(
    .dstregpreRR(dstregpreRR2),
    .srcreg1_num(srcreg11_num),
    .srcreg2_num(srcreg12_num),
    .is_loadpreRR(is_loadpreRR2),
    .is_stall(is_stall2)
);

hazard_detector hazard_detector3(
    .dstregpreRR(dstregpreRR2),
    .srcreg1_num(srcreg21_num),
    .srcreg2_num(srcreg22_num),
    .is_loadpreRR(is_loadpreRR2),
    .is_stall(is_stall3)
);
// 前の命令との依存関係を確認
assign is_stall = is_stall0 | is_stall1 | is_stall2 | is_stall3;
// 同時実行命令との依存関係を確認
assign depend = ((dstreg1_num == srcreg21_num) && (srcreg21_num != 0)) | ((dstreg1_num == srcreg22_num) && (srcreg22_num != 0));

branch_predictor branch_predictor0(
    .clk(clk),
    .rst(rst),
    .alucode_reg1(alucode_reg1),
    .alucode_reg2(alucode_reg2),
    .alucodeRR1(alucodeRR1),
    .alucodeRR2(alucodeRR2),
    .opcodeRR1(opcodeRR1),
    .opcodeRR2(opcodeRR2),
    .IFpc1(IFpc1),
    .IFpc2(IFpc2),
    .is_jump1(is_jump1),
    .is_jump2(is_jump2),
    .imm1(imm_dpl1),
    .imm2(imm_dpl2),
    .pre_branch1(pre_branch1),
    .pre_branch2(pre_branch2),
    .predict_pc1(predict_pc1),
    .predict_pc2(predict_pc2)
);

always@ (posedge clk or negedge rst) begin
    if (!rst) begin
        dstregpreRR1 <= 5'd0;
        dstregpreRR2 <= 5'd0;
        immpreRR1 <= 32'd0;
        immpreRR2 <= 32'd0;
        alucodepreRR1 <= `ALU_NOP;
        alucodepreRR2 <= `ALU_NOP;
        aluop1_typepreRR1 <= `OP_TYPE_NONE;
        aluop2_typepreRR1 <= `OP_TYPE_NONE;
        aluop1_typepreRR2 <= `OP_TYPE_NONE;
        aluop2_typepreRR2 <= `OP_TYPE_NONE;
        reg_wepreRR1 <= `DISABLE;
        reg_wepreRR2 <= `DISABLE;
        is_loadpreRR1 <= `DISABLE;
        is_loadpreRR2 <= `DISABLE;
        is_storepreRR1 <= `DISABLE;
        is_storepreRR2 <= `DISABLE;
        preRRpc1 <= 32'd0;
        preRRpc2 <= 32'd0;
        funct3preRR1 <= 3'd0;
        funct3preRR2 <= 3'd0;
        srcreg11 <= 5'd0;
        srcreg12 <= 5'd0;
        srcreg21 <= 5'd0;
        srcreg22 <= 5'd0;
        opcodepreRR1 <= 7'd0;
        opcodepreRR2 <= 7'd0;
        prePC1 <= 32'd0;
        prePC2 <= 32'd0;
    end
    else if (is_stall | fail) begin
        dstregpreRR1 <= 5'd0;
        dstregpreRR2 <= 5'd0;
        immpreRR1 <= 32'd0;
        immpreRR2 <= 32'd0;
        alucodepreRR1 <= `ALU_NOP;
        alucodepreRR2 <= `ALU_NOP;
        aluop1_typepreRR1 <= `OP_TYPE_NONE;
        aluop2_typepreRR1 <= `OP_TYPE_NONE;
        aluop1_typepreRR2 <= `OP_TYPE_NONE;
        aluop2_typepreRR2 <= `OP_TYPE_NONE;
        reg_wepreRR1 <= `DISABLE;
        reg_wepreRR2 <= `DISABLE;
        is_loadpreRR1 <= `DISABLE;
        is_loadpreRR2 <= `DISABLE;
        is_storepreRR1 <= `DISABLE;
        is_storepreRR2 <= `DISABLE;
        preRRpc1 <= 32'd0;
        preRRpc2 <= 32'd0;
        funct3preRR1 <= 3'd0;
        funct3preRR2 <= 3'd0;
        srcreg11 <= 5'd0;
        srcreg12 <= 5'd0;
        srcreg21 <= 5'd0;
        srcreg22 <= 5'd0;
        opcodepreRR1 <= 7'd0;
        opcodepreRR2 <= 7'd0;
        prePC1 <= 32'd0;
        prePC2 <= 32'd0;
    end
    else if (depend | pre_branch1) begin
        dstregpreRR1 <= dstreg1_num;
        dstregpreRR2 <= 5'd0;
        immpreRR1 <= imm_dpl1;
        immpreRR2 <= 32'd0;
        alucodepreRR1 <= alucode_reg1;
        alucodepreRR2 <= `ALU_NOP;
        aluop1_typepreRR1 <= aluop11;
        aluop2_typepreRR1 <= aluop12;
        aluop1_typepreRR2 <= `OP_TYPE_NONE;
        aluop2_typepreRR2 <= `OP_TYPE_NONE;
        reg_wepreRR1 <= we1;
        reg_wepreRR2 <= `DISABLE;
        is_loadpreRR1 <= load1;
        is_loadpreRR2 <= `DISABLE;
        is_storepreRR1 <= store1;
        is_storepreRR2 <= `DISABLE;
        preRRpc1 <= IFpc1;
        preRRpc2 <= 32'd0;
        funct3preRR1 <= funct3_1;
        funct3preRR2 <= 3'd0;
        srcreg11 <= srcreg11_num;
        srcreg12 <= srcreg12_num;
        srcreg21 <= 5'd0;
        srcreg22 <= 5'd0;
        opcodepreRR1 <= opcode_wire1;
        opcodepreRR2 <= 7'd0;
        prePC1 <= predict_pc1;
        prePC2 <= 32'd0;
    end
    else begin
        dstregpreRR1 <= dstreg1_num;
        dstregpreRR2 <= dstreg2_num;
        immpreRR1 <= imm_dpl1;
        immpreRR2 <= imm_dpl2;
        alucodepreRR1 <= alucode_reg1;
        alucodepreRR2 <= alucode_reg2;
        aluop1_typepreRR1 <= aluop11;
        aluop2_typepreRR1 <= aluop12;
        aluop1_typepreRR2 <= aluop21;
        aluop2_typepreRR2 <= aluop22;
        reg_wepreRR1 <= we1;
        reg_wepreRR2 <= we2;
        is_loadpreRR1 <= load1;
        is_loadpreRR2 <= load2;
        is_storepreRR1 <= store1;
        is_storepreRR2 <= store2;
        preRRpc1 <= IFpc1;
        preRRpc2 <= IFpc2;
        funct3preRR1 <= funct3_1;
        funct3preRR2 <= funct3_2;
        srcreg11 <= srcreg11_num;
        srcreg12 <= srcreg12_num;
        srcreg21 <= srcreg21_num;
        srcreg22 <= srcreg22_num;
        opcodepreRR1 <= opcode_wire1;
        opcodepreRR2 <= opcode_wire2;
        prePC1 <= predict_pc1;
        prePC2 <= predict_pc2;
    end
end
endmodule