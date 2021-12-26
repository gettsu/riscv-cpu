`include "define.vh"

module branch_predictor(
    input wire clk,
    input wire rst,
    input wire [5:0] alucode_reg1, // preRRステージのもの
    input wire [5:0] alucode_reg2,
    input wire [5:0] alucodeRR1,   // EXステージのもの
    input wire [5:0] alucodeRR2,
    input wire [6:0] opcodeRR1,
    input wire [6:0] opcodeRR2,
    input wire [31:0] IFpc1,       // preRRステージでのプラグラムカウンタ
    input wire [31:0] IFpc2,
    input wire is_jump1,
    input wire is_jump2,
    input wire [31:0] imm1,
    input wire [31:0] imm2,        
    output reg pre_branch1,        // 分岐予測
    output reg pre_branch2,
    output reg [31:0] predict_pc1,  // 分岐先予測プログラムカウンタ
    output reg [31:0] predict_pc2
);

reg [3:0] beq, bne, blt, bge, bltu, bgeu, none;
reg [1:0] beq_ptable [0:15];
reg [1:0] bne_ptable [0:15];
reg [1:0] blt_ptable [0:15];
reg [1:0] bge_ptable [0:15];
reg [1:0] bltu_ptable [0:15];
reg [1:0] bgeu_ptable [0:15];

// 初期化
integer i;
always@(posedge clk or negedge rst) begin
    if (!rst) begin
        for (i = 0;i < 16; i = i+1) begin
            beq_ptable[i] <= 2'd1;
            bne_ptable[i] <= 2'd1;
            blt_ptable[i] <= 2'd1;
            bge_ptable[i] <= 2'd1;
            bltu_ptable[i] <= 2'd1;
            bgeu_ptable[i] <= 2'd1;
        end
        beq <= 4'd0;
        bne <= 4'd0;
        blt <= 4'd0;
        bge <= 4'd0;
        bltu <= 4'd0;
        bgeu <= 4'd0;
        none <= 4'd0;
    end
    else begin
        if (opcodeRR1 == `BRANCH) begin
        case (alucodeRR1)
           `ALU_BEQ: begin
               beq <= {beq[2:0],is_jump1};
               case (beq_ptable[beq])
                   2'd0: beq_ptable[beq] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) beq_ptable[beq] <= 2'd2;
                        else beq_ptable[beq] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) beq_ptable[beq] <= 2'd3;
                       else beq_ptable[beq] <= 2'd1;
                   end
                   default: beq_ptable[beq] <= {1'b1,is_jump1};
               endcase
           end
           `ALU_BNE: begin
               bne <= {bne[2:0],is_jump1};
               case (bne_ptable[bne])
                   2'd0: bne_ptable[bne] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) bne_ptable[bne] <= 2'd2;
                        else bne_ptable[bne] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) bne_ptable[bne] <= 2'd3;
                       else bne_ptable[bne] <= 2'd1;
                   end
                   default: bne_ptable[bne] <= {1'b1,is_jump1};
               endcase
            end
           `ALU_BLT: begin
               blt <= {blt[2:0],is_jump1};
               case (blt_ptable[blt])
                   2'd0: blt_ptable[blt] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) blt_ptable[blt] <= 2'd2;
                        else blt_ptable[blt] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) blt_ptable[blt] <= 2'd3;
                       else blt_ptable[blt] <= 2'd1;
                   end
                   default: blt_ptable[blt] <= {1'b1,is_jump1};
               endcase
           end
           `ALU_BGE: begin
               bge <= {bge[2:0],is_jump1};
               case (bge_ptable[bge])
                   2'd0: bge_ptable[bge] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) bge_ptable[bge] <= 2'd2;
                        else bge_ptable[bge] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) bge_ptable[bge] <= 2'd3;
                       else bge_ptable[bge] <= 2'd1;
                   end
                   default: bge_ptable[bge] <= {1'b1,is_jump1};
               endcase
           end
           `ALU_BLTU: begin
               bltu <= {bltu[2:0],is_jump1};
               case (bltu_ptable[bltu])
                   2'd0: bltu_ptable[bltu] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) bltu_ptable[bltu] <= 2'd2;
                        else bltu_ptable[bltu] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) bltu_ptable[bltu] <= 2'd3;
                       else bltu_ptable[bltu] <= 2'd1;
                   end
                   default: bltu_ptable[bltu] <= {1'b1,is_jump1};
               endcase
           end
           `ALU_BGEU: begin
               bgeu <= {bgeu[2:0],is_jump1};
               case (bgeu_ptable[bgeu])
                   2'd0: bgeu_ptable[bgeu] <= {1'b0,is_jump1};
                   2'd1: begin
                        if (is_jump1) bgeu_ptable[bgeu] <= 2'd2;
                        else bgeu_ptable[bgeu] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump1) bgeu_ptable[bgeu] <= 2'd3;
                       else bgeu_ptable[bgeu] <= 2'd1;
                   end
                   default: bgeu_ptable[bgeu] <= {1'b1,is_jump1};
               endcase
           end
           default: begin
               none <= 4'd0;
           end
        endcase
        end

        if (opcodeRR2 == `BRANCH && !is_jump1) begin
        case (alucodeRR2)
           `ALU_BEQ: begin
               beq <= {beq[2:0],is_jump2};
               case (beq_ptable[beq])
                   2'd0: beq_ptable[beq] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) beq_ptable[beq] <= 2'd2;
                        else beq_ptable[beq] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) beq_ptable[beq] <= 2'd3;
                       else beq_ptable[beq] <= 2'd1;
                   end
                   default: beq_ptable[beq] <= {1'b1,is_jump2};
               endcase
           end
           `ALU_BNE: begin
               bne <= {bne[2:0],is_jump2};
               case (bne_ptable[bne])
                   2'd0: bne_ptable[bne] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) bne_ptable[bne] <= 2'd2;
                        else bne_ptable[bne] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) bne_ptable[bne] <= 2'd3;
                       else bne_ptable[bne] <= 2'd1;
                   end
                   default: bne_ptable[bne] <= {1'b1,is_jump2};
               endcase
            end
           `ALU_BLT: begin
               blt <= {blt[2:0],is_jump2};
               case (blt_ptable[blt])
                   2'd0: blt_ptable[blt] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) blt_ptable[blt] <= 2'd2;
                        else blt_ptable[blt] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) blt_ptable[blt] <= 2'd3;
                       else blt_ptable[blt] <= 2'd1;
                   end
                   default: blt_ptable[blt] <= {1'b1,is_jump2};
               endcase
           end
           `ALU_BGE: begin
               bge <= {bge[2:0],is_jump2};
               case (bge_ptable[bge])
                   2'd0: bge_ptable[bge] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) bge_ptable[bge] <= 2'd2;
                        else bge_ptable[bge] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) bge_ptable[bge] <= 2'd3;
                       else bge_ptable[bge] <= 2'd1;
                   end
                   default: bge_ptable[bge] <= {1'b1,is_jump2};
               endcase
           end
           `ALU_BLTU: begin
               bltu <= {bltu[2:0],is_jump2};
               case (bltu_ptable[bltu])
                   2'd0: bltu_ptable[bltu] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) bltu_ptable[bltu] <= 2'd2;
                        else bltu_ptable[bltu] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) bltu_ptable[bltu] <= 2'd3;
                       else bltu_ptable[bltu] <= 2'd1;
                   end
                   default: bltu_ptable[bltu] <= {1'b1,is_jump2};
               endcase
           end
           `ALU_BGEU: begin
               bgeu <= {bgeu[2:0],is_jump2};
               case (bgeu_ptable[bgeu])
                   2'd0: bgeu_ptable[bgeu] <= {1'b0,is_jump2};
                   2'd1: begin
                        if (is_jump2) bgeu_ptable[bgeu] <= 2'd2;
                        else bgeu_ptable[bgeu] <= 2'd0;
                   end
                   2'd2: begin
                       if (is_jump2) bgeu_ptable[bgeu] <= 2'd3;
                       else bgeu_ptable[bgeu] <= 2'd1;
                   end
                   default: bgeu_ptable[bgeu] <= {1'b1,is_jump2};
               endcase
           end
           default: begin
               none <= 4'd0;
           end
        endcase
        end
    end 
end

// 出力
always@(*) begin
    case (alucode_reg1)
        `ALU_JAL: begin
            pre_branch1 = `ENABLE;
            predict_pc1 = IFpc1 + imm1;
        end
        `ALU_JALR: begin
            pre_branch1 = `DISABLE;
            predict_pc1 = IFpc1 + 32'd4;
        end
        `ALU_BEQ: begin
            if (beq_ptable[beq] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        `ALU_BNE: begin
            if (bne_ptable[bne] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        `ALU_BLT: begin
            if (blt_ptable[blt] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        `ALU_BGE: begin
            if (bge_ptable[bge] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        `ALU_BLTU: begin
            if (bltu_ptable[bltu] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        `ALU_BGEU: begin
            if (bgeu_ptable[bgeu] >= 2'd2) begin
                pre_branch1 = `ENABLE;
                predict_pc1 = IFpc1 + imm1;
            end
            else begin
                pre_branch1 = `DISABLE; 
                predict_pc1 = IFpc1 + 32'd4;
            end
        end
        default : begin
            pre_branch1 = `DISABLE;
            predict_pc1 = IFpc1 + 32'd4;
        end
    endcase

    case (alucode_reg2)
        `ALU_JAL: begin
            pre_branch2 = `ENABLE;
            predict_pc2 = IFpc2 + imm2;
        end
        `ALU_JALR: begin
            pre_branch2 = `DISABLE;
            predict_pc2 = IFpc2 + 32'd4;
        end
        `ALU_BEQ: begin
            if (beq_ptable[beq] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        `ALU_BNE: begin
            if (bne_ptable[bne] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        `ALU_BLT: begin
            if (blt_ptable[blt] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        `ALU_BGE: begin
            if (bge_ptable[bge] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        `ALU_BLTU: begin
            if (bltu_ptable[bltu] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        `ALU_BGEU: begin
            if (bgeu_ptable[bgeu] >= 2'd2) begin
                pre_branch2 = `ENABLE;
                predict_pc2 = IFpc2 + imm2;
            end
            else begin
                pre_branch2 = `DISABLE; 
                predict_pc2 = IFpc2 + 32'd4;
            end
        end
        default : begin
            pre_branch2 = `DISABLE;
            predict_pc2 = IFpc2 + 32'd4;
        end
    endcase
end

endmodule