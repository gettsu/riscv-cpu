`include "define.vh"
module operand_switcher(
    input wire [31:0] regdata1,
    input wire [31:0] regdata2,
    input wire [31:0] imm,
    input wire [31:0] pc,
    input wire [1:0] aluop1_type,
    input wire [1:0] aluop2_type,
    output wire [31:0] op1,
    output wire [31:0] op2
);

function [31:0] op_switch;
    input [31:0] regdata, imm, pc;
    input [1:0] aluoptype;
    begin
        case (aluoptype)
            `OP_TYPE_NONE: op_switch = 32'd0;
            `OP_TYPE_REG: op_switch = regdata;
            `OP_TYPE_IMM: op_switch = imm;
            `OP_TYPE_PC: op_switch = pc;
            default: op_switch = 32'd0;
        endcase
    end
endfunction

assign op1 = op_switch(regdata1,imm,pc,aluop1_type);
assign op2 = op_switch(regdata2,imm,pc,aluop2_type);

endmodule
