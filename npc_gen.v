// 不要になってしまった...

`include "define.vh"
module npc_gen(
    input wire [31:0] pc,
    input wire [1:0] br_taken,
    input wire [31:0] imm,
    input wire is_stall,
    input wire [31:0] op1,
    output wire [31:0] npc
);

function [31:0] next_pc;
    input [31:0] pc;
    input [1:0] br_taken;
    input [31:0] imm;
    input [31:0] op1;
    input is_stall;
    begin
        if (is_stall) next_pc = pc;
        else if (br_taken == 2'd0) next_pc = pc + 32'd4; 
        else if (br_taken == 2'd1) next_pc = pc + imm;
        else if (br_taken == 2'd2) next_pc = op1 + imm;
        else next_pc = pc + 32'd4;
    end
endfunction

assign npc = next_pc(pc,br_taken,imm,op1,is_stall);
endmodule
