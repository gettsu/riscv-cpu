`include "define.vh"
module alu(
    input wire [31:0] op1,
    input wire [31:0] op2,
    input wire [5:0] alucode,
    output wire [31:0] alu_result,
    output wire [1:0] br_taken
);

function [31:0] result;
    input [31:0] op1, op2;
    input [5:0] alucode;
    begin
        case (alucode)
            `ALU_LUI: result = op2;
            `ALU_JAL: result = op2 + 32'h4;
            `ALU_JALR: result = op2 + 32'h4;
            `ALU_LB: result = op1 + op2;
            `ALU_LH: result = op1 + op2;
            `ALU_LW: result = op1 + op2;
            `ALU_LBU: result = op1 + op2;
            `ALU_LHU: result = op1 + op2;
            `ALU_SB: result = op1 + op2;
            `ALU_SH: result = op1 + op2;
            `ALU_SW: result = op1 + op2;
            `ALU_ADD: result = op1 + op2;
            `ALU_SUB: result = op1 - op2;
            `ALU_SLT: result = {{31{1'b0}},($signed(op1) < $signed(op2))};
            `ALU_SLTU: result = {{31{1'b0}},(op1 < op2)};
            `ALU_XOR: result = op1 ^ op2;
            `ALU_OR: result = op1 | op2;
            `ALU_AND: result = op1 & op2;
            `ALU_SLL: result = op1 << op2[4:0];
            `ALU_SRL: result = op1 >> op2[4:0];
            `ALU_SRA: result = ($signed(op1) >>> op2[4:0]);
            `ALU_NOP: result = 32'h0;
            default: result = 32'h0;
        endcase
     end
endfunction

function [1:0] branch;
    input [31:0] op1, op2;
    input [5:0] alucode;
    begin
        case (alucode)
            `ALU_JAL: branch = 2'd1;
            `ALU_JALR: branch = 2'd2;
            `ALU_BEQ: branch = {1'b0,(op1 == op2)};
            `ALU_BNE: branch = {1'b0,(op1 != op2)};
            `ALU_BLT: branch = {1'b0,($signed(op1) < $signed(op2))};
            `ALU_BGE: branch = {1'b0,($signed(op1) >= $signed(op2))};
            `ALU_BLTU: branch = {1'b0,(op1 < op2)};
            `ALU_BGEU: branch = {1'b0,(op1 >= op2)};
            default: branch = 2'd0;
        endcase
    end
endfunction
assign alu_result = result(op1, op2, alucode);
assign br_taken = branch(op1, op2, alucode);

endmodule


