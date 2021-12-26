`include "define.vh"
module decoder(
    input wire [31:0] ir,
    output wire [4:0] srcreg1_num,
    output wire [4:0] srcreg2_num,
    output wire [4:0] dstreg_num,
    output wire [31:0] imm,
    output reg [5:0] alucode,
    output reg [1:0] aluop1_type,
    output reg [1:0] aluop2_type,
    output reg       reg_we,
    output reg       is_load,
    output reg       is_store,
    output reg       is_halt,
    output wire [2:0] funct3
);
wire [6:0] funct7;
wire [6:0] opcode;
wire [2:0] optype;
assign funct7 = ir[31:25];
assign funct3 = ir[14:12];
assign opcode = ir[6:0];

function [31:0] imm_ret;
    input [31:0] ir;
    input [2:0] optype;
    input [2:0] funct3;
    input [6:0] opcode;
    begin
       case (optype)
           `TYPE_NONE: imm_ret = 32'd0;
           `TYPE_U: imm_ret = {ir[31:12], {12{1'b0}}};
           `TYPE_J: imm_ret = {{12{ir[31]}},ir[19:12],ir[20],ir[30:21],1'b0};
           `TYPE_I: begin
               if (opcode == `LOAD) begin
                   imm_ret = {{20{ir[31]}},ir[31:20]};
               end
               else if (funct3 == 3'd1 || funct3 == 3'd5) begin
                   imm_ret = {{27{1'b0}},ir[24:20]};
               end
               else begin
                   imm_ret = {{20{ir[31]}},ir[31:20]};
               end
           end
           `TYPE_B: imm_ret = {{20{ir[31]}},ir[7],ir[30:25],ir[11:8],1'b0};
           `TYPE_S: imm_ret = {{20{ir[31]}},ir[31:25],ir[11:7]};
           `TYPE_R: imm_ret = 32'd0;
           default: imm_ret = 32'd0;
       endcase
    end
endfunction

function [4:0] src_reg1;
    input [31:0] ir;
    input [2:0] optype;
    begin
       case (optype)
           `TYPE_I: src_reg1 = ir[19:15];
           `TYPE_B: src_reg1 = ir[19:15];
           `TYPE_S: src_reg1 = ir[19:15];
           `TYPE_R: src_reg1 = ir[19:15];
           default: src_reg1 = 5'd0;
       endcase
    end
endfunction

function [4:0] src_reg2;
input [31:0] ir;
input [2:0] optype;
    begin
       case (optype)
           `TYPE_B: src_reg2 = ir[24:20];
           `TYPE_S: src_reg2 = ir[24:20];
           `TYPE_R: src_reg2 = ir[24:20];
           default: src_reg2 = 5'd0;
       endcase
    end
endfunction

function [4:0] dst_reg;
    input [31:0] ir;
    input [2:0] optype;
    begin
        case (optype)
            `TYPE_U: dst_reg = ir[11:7];
            `TYPE_J: dst_reg = ir[11:7];
            `TYPE_I: dst_reg = ir[11:7];
            `TYPE_R: dst_reg = ir[11:7];
            default: dst_reg = 5'd0;
        endcase
    end
endfunction

function [2:0] opType;
    input [6:0] opcode;
    begin
        case (opcode)
            `LUI: opType = `TYPE_U;
            `AUIPC: opType = `TYPE_U;
            `JAL: opType = `TYPE_J;
            `JALR: opType = `TYPE_I;
            `BRANCH: opType = `TYPE_B;
            `LOAD: opType = `TYPE_I;
            `STORE: opType = `TYPE_S;
            `OPIMM: opType = `TYPE_I;
            `OP: opType = `TYPE_R;
            default: opType = `TYPE_NONE;
        endcase
    end
endfunction

assign optype = opType(opcode);
assign imm = imm_ret(ir,optype,funct3,opcode);
assign srcreg1_num = src_reg1(ir,optype);
assign srcreg2_num = src_reg2(ir,optype);
assign dstreg_num = dst_reg(ir,optype);

always @(*) begin
    case (opcode)
        `LUI: begin
            alucode = `ALU_LUI;
            aluop1_type = `OP_TYPE_NONE;
            aluop2_type = `OP_TYPE_IMM;
            reg_we = `ENABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
        end
        `AUIPC: begin
            alucode = `ALU_ADD;
            aluop1_type = `OP_TYPE_IMM;
            aluop2_type = `OP_TYPE_PC;
            reg_we = `ENABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
        end
        `JAL: begin
            alucode = `ALU_JAL;
            aluop1_type = `OP_TYPE_NONE;
            aluop2_type = `OP_TYPE_PC;
            if (dstreg_num == 5'd0) begin
                reg_we = `DISABLE;
            end
            else begin
                reg_we = `ENABLE;
            end
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
        end
        `JALR: begin
            alucode = `ALU_JALR;
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_PC;
            if (dstreg_num == 5'd0) begin
                reg_we = `DISABLE;
            end
            else begin
                reg_we = `ENABLE;
            end
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
        end
        `BRANCH: begin
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_REG;
            reg_we = `DISABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
            if (funct3 == 3'd0) begin
                alucode = `ALU_BEQ;
            end
            else if (funct3 == 3'd1) begin
                alucode = `ALU_BNE;
            end
            else if (funct3 == 3'd4) begin
                alucode = `ALU_BLT;
            end
            else if (funct3 == 3'd5) begin
                alucode = `ALU_BGE;
            end
            else if (funct3 == 3'd6) begin
                alucode = `ALU_BLTU;
            end
            else if (funct3 == 3'd7) begin
                alucode = `ALU_BGEU;
            end
            else begin
                alucode = `ALU_NOP;
            end
         end
        `LOAD: begin
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_IMM;
            reg_we = `ENABLE;
            is_load = `ENABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
            if (funct3 == 3'd0) begin
                alucode = `ALU_LB;
            end
            else if (funct3 == 3'd1) begin
                alucode = `ALU_LH;
            end
            else if (funct3 == 3'd2) begin
                alucode = `ALU_LW;
            end
            else if (funct3 == 3'd4) begin
                alucode = `ALU_LBU;
            end
            else if (funct3 == 3'd5) begin
                alucode = `ALU_LHU;
            end
            else begin
                alucode = `ALU_NOP;
            end
        end
        `STORE: begin
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_IMM;
            reg_we = `DISABLE;
            is_load = `DISABLE;
            is_store = `ENABLE;
            is_halt = `DISABLE;
            if (funct3 == 3'd0) begin
                alucode = `ALU_SB;
            end
            else if (funct3 == 3'd1) begin
                alucode = `ALU_SH;
            end
            else if (funct3 == 3'd2) begin
                alucode = `ALU_SW;
            end
            else begin
                alucode = `ALU_NOP;
            end
        end
        `OPIMM: begin
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_IMM;
            reg_we = `ENABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
            if (funct3 == 3'd0) begin
                alucode = `ALU_ADD;
            end
            else if (funct3 == 3'd2) begin
                alucode = `ALU_SLT;
            end
            else if (funct3 == 3'd3) begin
                alucode = `ALU_SLTU;
            end
            else if (funct3 == 3'd4) begin
                alucode = `ALU_XOR;
            end
            else if (funct3 == 3'd6) begin
                alucode = `ALU_OR;
            end
            else if (funct3 == 3'd7) begin
                alucode = `ALU_AND;
            end
            else if (funct3 == 3'd1) begin
                alucode = `ALU_SLL;
            end
            else if (funct3 == 3'd5 && funct7 == 7'd0) begin
                alucode = `ALU_SRL;
            end
            else if (funct3 == 3'd5 && funct7 == 7'd32) begin
                alucode = `ALU_SRA;
            end
            else begin
                alucode = `ALU_NOP;
            end
        end
        `OP: begin
            aluop1_type = `OP_TYPE_REG;
            aluop2_type = `OP_TYPE_REG;
            reg_we = `ENABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
            if (funct3 == 3'd0 && funct7 == 7'd0) begin
                alucode = `ALU_ADD;
            end
            else if (funct3 == 3'd0 && funct7 == 7'd32) begin
                alucode = `ALU_SUB;
            end
            else if (funct3 == 3'd1) begin
                alucode = `ALU_SLL;
            end
            else if (funct3 == 3'd2) begin
                alucode = `ALU_SLT;
            end
            else if (funct3 == 3'd3) begin
                alucode = `ALU_SLTU;
            end
            else if (funct3 == 3'd4) begin
                alucode = `ALU_XOR;
            end
            else if (funct3 == 3'd5 && funct7 == 7'd0) begin
                alucode = `ALU_SRL;
            end
            else if (funct3 == 3'd5 && funct7 == 7'd32) begin
                alucode = `ALU_SRA;
            end
            else if (funct3 == 3'd6) begin
                alucode = `ALU_OR;
            end
            else if (funct3 == 3'd7) begin
                alucode = `ALU_AND;
            end
            else begin
                alucode = `ALU_NOP;
            end
        end
        default: begin
            aluop1_type = `OP_TYPE_NONE;
            aluop2_type = `OP_TYPE_NONE;
            reg_we = `DISABLE;
            is_load = `DISABLE;
            is_store = `DISABLE;
            is_halt = `DISABLE;
            alucode = `ALU_NOP;
        end
    endcase
end

endmodule