module IF(
    input wire clk,
    input wire rst,
    input wire [31:0] pc1, pc2,
    input wire is_stall,
    input wire depend,
    input wire [31:0] jump_pc,
    input wire pre_branch1, pre_branch2, // 分岐予測で分岐するか
    input wire fail,       // 分岐予測失敗
    input wire [31:0] predict_pc1, predict_pc2,
    output wire [31:0] npc,
    output wire [31:0] ir1, ir2,
    output reg [31:0] IFpc1, IFpc2
);

wire [31:0] r_addr1,r_addr2;
assign r_addr1 = {{2{1'd0}},pc1[31:2]};
assign r_addr2 = {{2{1'd0}},pc2[31:2]};

function [31:0] next_pc;
    input is_stall;
    input fail;
    input pre_branch1, pre_branch2;
    input [31:0] pc1;
    input [31:0] jump_pc;
    input [31:0] predict_pc1, predict_pc2;
    input depend;
    begin
        if (fail) begin
            next_pc = jump_pc;
        end
        else if (is_stall | depend) begin
            next_pc = pc1;
        end
        else if (pre_branch1) begin
            next_pc = predict_pc1;
        end
        else if (pre_branch2) begin
            next_pc = predict_pc2;
        end
        else begin
            next_pc = pc1 + 32'd8;
        end
    end
endfunction 

assign npc = next_pc(is_stall, fail, pre_branch1, pre_branch2, pc1, jump_pc, predict_pc1, predict_pc2, depend);

rom rom0(
    .clk(clk),
    .rst(rst),
    .is_stall(is_stall),
    .depend(depend),
    .fail(fail),
    .pre_branch1(pre_branch1),
    .pre_branch2(pre_branch2),
    .r_addr1(r_addr1),
    .r_addr2(r_addr2),
    .r_data1(ir1),
    .r_data2(ir2)
);

always @ (posedge clk or negedge rst) begin
    if (!rst) begin
        IFpc1 <= 32'd0;
        IFpc2 <= 32'd0;
    end
    else if (fail) begin
        IFpc1 <= 32'd0;
        IFpc2 <= 32'd0;
    end
    else if (pre_branch1 && !is_stall) begin
        IFpc1 <= 32'd0;
        IFpc2 <= 32'd0;
    end 
    else if (depend && !is_stall) begin
        IFpc1 <= 32'd0; 
    end
    else if (pre_branch2 && !is_stall) begin
        IFpc1 <= 32'd0;
        IFpc2 <= 32'd0;
    end
    else if (!is_stall) begin
        IFpc1 <= pc1;
        IFpc2 <= pc2;
    end
end
endmodule