`include "define.vh"
module EX(
    input wire clk,
    input wire rst,
    input wire [31:0] r_dataRR11, r_dataRR12, r_dataRR21, r_dataRR22,
    input wire [6:0] opcodeRR1, opcodeRR2,
    input wire [4:0] dstregRR1, dstregRR2,
    input wire [31:0] immRR1, immRR2,
    input wire [5:0] alucodeRR1, alucodeRR2,
    input wire [1:0] aluop1_typeRR1, aluop2_typeRR1,
    input wire [1:0] aluop1_typeRR2, aluop2_typeRR2,
    input wire [2:0] funct3RR1, funct3RR2,
    input wire [31:0] loadvalue_wordMA1, loadvalue_wordMA2,
    input wire reg_weRR1, is_loadRR1, is_storeRR1,
    input wire reg_weRR2, is_loadRR2, is_storeRR2,
    input wire [31:0] RRpc1, RRpc2,
    input wire [2:0] forwarding11, forwarding12, forwarding21, forwarding22,
    input wire [31:0] wb_dataRW1, wb_dataRW2,
    input wire [31:0] prePCRR1, prePCRR2,
    output reg [31:0] aluresultEX1, aluresultEX2,
    output reg [31:0] write_addressEX1, write_addressEX2,
    output reg [31:0] read_addressEX1, read_addressEX2,
    output reg [31:0] storevalue_wordEX1, storevalue_wordEX2,
    output reg [3:0] write_en_bmEX1, write_en_bmEX2,
    output reg [4:0] dstregEX1, dstregEX2,
    output reg reg_weEX1, is_loadEX1, is_storeEX1,
    output reg reg_weEX2, is_loadEX2, is_storeEX2,
    output wire is_jump1,
    output wire is_jump2,
    output wire [31:0] jump_pc,
    output wire [31:0] load_reg_valueMA1, load_reg_valueMA2,
    output reg [4:0] dstregMA1, dstregMA2,
    output reg [31:0] aluresultMA1, aluresultMA2,
    output reg reg_weMA1, is_loadMA1,
    output reg reg_weMA2, is_loadMA2,
    
    output wire [31:0] r_data12, r_data22, //デバッグ用
    output wire fail   //分岐予測失敗
); 

wire [31:0] op11, op12, op21, op22;
wire [31:0] aluresult1, aluresult2;
wire [1:0] br_taken1, br_taken2;
wire [31:0] storevalue_word1, storevalue_word2;
wire [31:0] read_address1, read_address2, write_address1, write_address2;
wire [3:0] write_en_bm1, write_en_bm2;

wire [31:0] r_data11;
// wire [31:0] r_data12;
wire [31:0] r_data21;
// wire [31:0] r_data22;

reg [2:0] funct3EX1, funct3EX2, funct3MA1, funct3MA2;
reg [31:0] read_addressMA1, read_addressMA2;

function [31:0] reg_forwarding;
    input [2:0] forwarding;
    input [31:0] r_dataRR;
    input [31:0] aluresultEX1;
    input [31:0] aluresultEX2;
    input [31:0] wb_dataRW1;
    input [31:0] wb_dataRW2;
    begin
        case(forwarding)
            3'd1: reg_forwarding = wb_dataRW1;
            3'd2: reg_forwarding = aluresultEX1;
            3'd3: reg_forwarding = wb_dataRW2;
            3'd4: reg_forwarding = aluresultEX2;
            default: reg_forwarding = r_dataRR;
        endcase
    end
endfunction

assign r_data11 = reg_forwarding(forwarding11, r_dataRR11, aluresultEX1, aluresultEX2, wb_dataRW1, wb_dataRW2);
assign r_data12 = reg_forwarding(forwarding12, r_dataRR12, aluresultEX1, aluresultEX2, wb_dataRW1, wb_dataRW2);
assign r_data21 = reg_forwarding(forwarding21, r_dataRR21, aluresultEX1, aluresultEX2, wb_dataRW1, wb_dataRW2);
assign r_data22 = reg_forwarding(forwarding22, r_dataRR22, aluresultEX1, aluresultEX2, wb_dataRW1, wb_dataRW2);

operand_switcher operand_switcher0(
    .regdata1(r_data11),
    .regdata2(r_data12),
    .imm(immRR1),
    .pc(RRpc1),
    .aluop1_type(aluop1_typeRR1),
    .aluop2_type(aluop2_typeRR1),
    .op1(op11),
    .op2(op12)
);

operand_switcher operand_switcher1(
    .regdata1(r_data21),
    .regdata2(r_data22),
    .imm(immRR2),
    .pc(RRpc2),
    .aluop1_type(aluop1_typeRR2),
    .aluop2_type(aluop2_typeRR2),
    .op1(op21),
    .op2(op22)
);

alu alu0(
    .op1(op11),
    .op2(op12),
    .alucode(alucodeRR1),
    .alu_result(aluresult1),
    .br_taken(br_taken1)
);

alu alu1(
    .op1(op21),
    .op2(op22),
    .alucode(alucodeRR2),
    .alu_result(aluresult2),
    .br_taken(br_taken2)
);

assign is_jump1 = |br_taken1;
assign is_jump2 = |br_taken2;

lsu lsu0(
    .alu_result(aluresult1),
    .write_data(r_data12),
    .is_store(is_storeRR1),
    .is_load(is_loadRR1),
    .funct3RR(funct3RR1),
    .funct3MA(funct3MA1),
    .loadvalue_word(loadvalue_wordMA1),
    .write_address(write_address1),
    .storevalue_word(storevalue_word1),
    .read_address(read_address1),
    .load_reg_value(load_reg_valueMA1),
    .write_en_bm(write_en_bm1),
    .read_addressMA(read_addressMA1)
);

lsu lsu1(
    .alu_result(aluresult2),
    .write_data(r_data22),
    .is_store(is_storeRR2),
    .is_load(is_loadRR2),
    .funct3RR(funct3RR2),
    .funct3MA(funct3MA2),
    .loadvalue_word(loadvalue_wordMA2),
    .write_address(write_address2),
    .storevalue_word(storevalue_word2),
    .read_address(read_address2),
    .load_reg_value(load_reg_valueMA2),
    .write_en_bm(write_en_bm2),
    .read_addressMA(read_addressMA2)
);

function [31:0] next_pc;
    input [31:0] pc;
    input [1:0] br_taken;
    input [31:0] imm;
    input [31:0] op1;
    begin
        if (br_taken == 2'd0) next_pc = pc + 32'd4; 
        else if (br_taken == 2'd1) next_pc = pc + imm;
        else if (br_taken == 2'd2) next_pc = op1 + imm;
        else next_pc = pc + 32'd4;
    end
endfunction

wire [31:0] jump_pc1, jump_pc2;
assign jump_pc1 = next_pc(RRpc1,br_taken1,immRR1,op11);
assign jump_pc2 = next_pc(RRpc2,br_taken2,immRR2,op21);

wire fail1, fail2;
assign fail1 = ((opcodeRR1 == `BRANCH) | (opcodeRR1 == `JALR)) & (jump_pc1 != prePCRR1);
assign fail2 = ((opcodeRR2 == `BRANCH) | (opcodeRR2 == `JALR)) & (jump_pc2 != prePCRR2);
assign fail = fail1|fail2;

assign jump_pc = (fail1) ? jump_pc1 : jump_pc2;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        aluresultEX1 <= 32'd0;
        write_addressEX1 <= 32'd0;
        read_addressEX1 <= 32'd0;
        storevalue_wordEX1 <= 32'd0;
        write_en_bmEX1 <= 4'd0;
        dstregEX1 <= 5'd0;
        reg_weEX1 <= `DISABLE;
        is_loadEX1 <= `DISABLE;
        is_storeEX1 <= `DISABLE;
        funct3EX1 <= 3'd0;
        dstregMA1 <= 5'd0;
        reg_weMA1 <= `DISABLE;
        aluresultMA1 <= 32'd0;
        is_loadMA1 <= `DISABLE;
        read_addressMA1 <= 32'd0;
        funct3MA1 <= 3'd0;
        aluresultEX2 <= 32'd0;
        write_addressEX2 <= 32'd0;
        read_addressEX2 <= 32'd0;
        storevalue_wordEX2 <= 32'd0;
        write_en_bmEX2 <= 4'd0;
        dstregEX2 <= 5'd0;
        reg_weEX2 <= `DISABLE;
        is_loadEX2 <= `DISABLE;
        is_storeEX2 <= `DISABLE;
        funct3EX2 <= 3'd0;
        dstregMA2 <= 5'd0;
        reg_weMA2 <= `DISABLE;
        aluresultMA2 <= 32'd0;
        is_loadMA2 <= `DISABLE;
        read_addressMA2 <= 32'd0;
        funct3MA2 <= 3'd0;
    end
    else if (is_jump1) begin
        aluresultEX1 <= aluresult1;
        write_addressEX1 <= write_address1;
        read_addressEX1 <= read_address1;
        storevalue_wordEX1 <= storevalue_word1;
        write_en_bmEX1 <= write_en_bm1;
        dstregEX1 <= dstregRR1;
        reg_weEX1 <= reg_weRR1;
        is_loadEX1 <= is_loadRR1;
        is_storeEX1 <= is_storeRR1;
        funct3EX1 <= funct3RR1;
        dstregMA1 <= dstregEX1;
        reg_weMA1 <= reg_weEX1;
        aluresultMA1 <= aluresultEX1;
        is_loadMA1 <= is_loadEX1;
        read_addressMA1 <= read_addressEX1;
        funct3MA1 <= funct3EX1;
        aluresultEX2 <= 32'd0;  // 1がジャンプしたら，2の内容は捨てられる．
        write_addressEX2 <= 32'd0;
        read_addressEX2 <= 32'd0;
        storevalue_wordEX2 <= 32'd0;
        write_en_bmEX2 <= 4'd0;
        dstregEX2 <= 5'd0;
        reg_weEX2 <= `DISABLE;
        is_loadEX2 <= `DISABLE;
        is_storeEX2 <= `DISABLE;
        funct3EX2 <= 3'd0;
        dstregMA2 <= dstregEX2;
        reg_weMA2 <= reg_weEX2;
        aluresultMA2 <= aluresultEX2;
        is_loadMA2 <= is_loadEX2;
        read_addressMA2 <= read_addressEX2;
        funct3MA2 <= funct3EX2;
    end
    else begin
        aluresultEX1 <= aluresult1;
        write_addressEX1 <= write_address1;
        read_addressEX1 <= read_address1;
        storevalue_wordEX1 <= storevalue_word1;
        write_en_bmEX1 <= write_en_bm1;
        dstregEX1 <= dstregRR1;
        reg_weEX1 <= reg_weRR1;
        is_loadEX1 <= is_loadRR1;
        is_storeEX1 <= is_storeRR1;
        funct3EX1 <= funct3RR1;
        dstregMA1 <= dstregEX1;
        reg_weMA1 <= reg_weEX1;
        aluresultMA1 <= aluresultEX1;
        is_loadMA1 <= is_loadEX1;
        read_addressMA1 <= read_addressEX1;
        funct3MA1 <= funct3EX1;
        aluresultEX2 <= aluresult2;
        write_addressEX2 <= write_address2;
        read_addressEX2 <= read_address2;
        storevalue_wordEX2 <= storevalue_word2;
        write_en_bmEX2 <= write_en_bm2;
        dstregEX2 <= dstregRR2;
        reg_weEX2 <= reg_weRR2;
        is_loadEX2 <= is_loadRR2;
        is_storeEX2 <= is_storeRR2;
        funct3EX2 <= funct3RR2;
        dstregMA2 <= dstregEX2;
        reg_weMA2 <= reg_weEX2;
        aluresultMA2 <= aluresultEX2;
        is_loadMA2 <= is_loadEX2;
        read_addressMA2 <= read_addressEX2;
        funct3MA2 <= funct3EX2;
    end
end

endmodule