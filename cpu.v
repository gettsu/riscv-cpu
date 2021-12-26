`include "define.vh"
module cpu(
    input wire clk_in,
    // input wire clk,
    input wire rst,
    output wire uart_tx
);
// プログラムカウンタ
reg [31:0] pc;
wire [31:0] npc;
wire [31:0] jump_pc;

// 制御信号
wire is_stall;
wire depend;

// 命令
wire [31:0] ir1, ir2;
wire [31:0] IFpc1, IFpc2;

// ライトバック
wire [4:0] dstregRW1, dstregRW2;
wire [31:0] wb_dataRW1, wb_dataRW2;
wire wb_enRW1, wb_enRW2;
wire pre_branch1, pre_branch2;
wire fail;

// preRRstage
wire [31:0] preRRpc1, preRRpc2;
wire is_jump1, is_jump2;
wire [4:0] dstregpreRR1, dstregpreRR2;
wire [31:0] immpreRR1, immpreRR2;
wire [5:0] alucodepreRR1, alucodepreRR2;
wire [1:0] aluop1_typepreRR1, aluop2_typepreRR1, aluop1_typepreRR2, aluop2_typepreRR2;
wire reg_wepreRR1, is_loadpreRR1, is_storepreRR1, reg_wepreRR2, is_loadpreRR2, is_storepreRR2;
wire [2:0] funct3preRR1, funct3preRR2;
wire [4:0] srcreg11, srcreg12, srcreg21, srcreg22;
wire [6:0] opcodepreRR1, opcodepreRR2;
wire [31:0] prePC1, prePC2;

// RRstage
wire [4:0] dstregRR1, dstregRR2;
wire [31:0] immRR1, immRR2;
wire [5:0] alucodeRR1, alucodeRR2;
wire [1:0] aluop1_typeRR1, aluop2_typeRR1, aluop1_typeRR2, aluop2_typeRR2;
wire reg_weRR1, reg_weRR2, is_loadRR1, is_loadRR2, is_storeRR1, is_storeRR2;
wire [31:0] r_data1RR1, r_data2RR1, r_data1RR2, r_data2RR2;
wire [31:0] RRpc1, RRpc2;
wire [2:0] funct3RR1, funct3RR2;
wire [31:0] prePCRR1, prePCRR2;
wire [6:0] opcodeRR1, opcodeRR2;
wire [4:0] srcreg11RR, srcreg12RR, srcreg21RR, srcreg22RR;
wire [31:0] predict_pc1, predict_pc2;

// EXstage
wire [31:0] aluresultEX1, aluresultEX2;
wire [31:0] write_addressEX1, write_addressEX2;
wire [31:0] read_addressEX1, read_addressEX2;
wire [31:0] storevalue_wordEX1, storevalue_wordEX2;
wire [3:0] write_en_bmEX1, write_en_bmEX2;
wire [4:0] dstregEX1, dstregEX2;
wire reg_weEX1, reg_weEX2, is_loadEX1, is_loadEX2, is_storeEX1, is_storeEX2;

// MAstage
wire [31:0] loadvalue_wordMA1, loadvalue_wordMA2;
wire [31:0] load_reg_valueMA1, load_reg_valueMA2;
wire [4:0] dstregMA1, dstregMA2;
wire [31:0] aluresultMA1, aluresultMA2;
wire reg_weMA1, reg_weMA2;
wire is_loadMA1, is_loadMA2;

// RWstage

// forwarding unit
wire [2:0] forwarding11, forwarding12, forwarding21, forwarding22;

// hardware_counter
wire [31:0] hc_OUT_data;
wire is_hw_count1, is_hw_count2;
assign is_hw_count1 = ((read_addressEX1 == `HARDWARE_COUNTER_ADDR) && (is_loadEX1 == `ENABLE)) ? 1'b1 : 1'b0;
assign is_hw_count2 = ((read_addressEX2 == `HARDWARE_COUNTER_ADDR) && (is_loadEX2 == `ENABLE)) ? 1'b1 : 1'b0;

// uart
wire [7:0] uart_IN_data;
wire uart_we1, uart_we2;
wire uart_we;

wire uart_OUT_data;
assign uart_we1 = ((write_addressEX1 == `UART_ADDR) && (is_storeEX1 == `ENABLE)) ? 1'b1 : 1'b0;
assign uart_we2 = ((write_addressEX2 == `UART_ADDR) && (is_storeEX2 == `ENABLE)) ? 1'b1 : 1'b0;

assign uart_we = uart_we1 | uart_we2;

assign uart_IN_data = uart_we1 ? storevalue_wordEX1[7:0] : storevalue_wordEX2[7:0];
assign uart_tx = uart_OUT_data;

wire [31:0] r_data12, r_data22;

wire clk;
clk_wiz_0 clk_wiz(
    .clk_in1(clk_in),
    .clk_out1(clk)
);

IF IF0(
    .clk(clk),
    .rst(rst),
    .pc1(pc),
    .pc2(pc + 32'd4),
    .is_stall(is_stall),
    .depend(depend),
    .jump_pc(jump_pc),
    .pre_branch1(pre_branch1),
    .pre_branch2(pre_branch2),
    .fail(fail),
    .predict_pc1(predict_pc1),
    .predict_pc2(predict_pc2),
    .npc(npc),
    .ir1(ir1),
    .ir2(ir2),
    .IFpc1(IFpc1),
    .IFpc2(IFpc2)
);

preRR preRR0(
    .clk(clk),
    .rst(rst),
    .ir1(ir1),
    .ir2(ir2),
    .IFpc1(IFpc1),
    .IFpc2(IFpc2),
    .is_jump1(is_jump1),
    .is_jump2(is_jump2),
    .fail(fail),
    .alucodeRR1(alucodeRR1),
    .alucodeRR2(alucodeRR2),
    .opcodeRR1(opcodeRR1),
    .opcodeRR2(opcodeRR2),
    .dstregpreRR1(dstregpreRR1),
    .dstregpreRR2(dstregpreRR2),
    .immpreRR1(immpreRR1),
    .immpreRR2(immpreRR2),
    .alucodepreRR1(alucodepreRR1),
    .alucodepreRR2(alucodepreRR2),
    .aluop1_typepreRR1(aluop1_typepreRR1),
    .aluop2_typepreRR1(aluop2_typepreRR1),
    .aluop1_typepreRR2(aluop1_typepreRR2),
    .aluop2_typepreRR2(aluop2_typepreRR2),
    .reg_wepreRR1(reg_wepreRR1),
    .reg_wepreRR2(reg_wepreRR2),
    .is_loadpreRR1(is_loadpreRR1),
    .is_loadpreRR2(is_loadpreRR2),
    .is_storepreRR1(is_storepreRR1),
    .is_storepreRR2(is_storepreRR2),
    .preRRpc1(preRRpc1),
    .preRRpc2(preRRpc2),
    .funct3preRR1(funct3preRR1),
    .funct3preRR2(funct3preRR2),
    .srcreg11(srcreg11),
    .srcreg12(srcreg12),
    .srcreg21(srcreg21),
    .srcreg22(srcreg22),
    .is_stall(is_stall),
    .pre_branch1(pre_branch1),
    .pre_branch2(pre_branch2),
    .predict_pc1(predict_pc1),
    .predict_pc2(predict_pc2),
    .prePC1(prePC1),
    .prePC2(prePC2),
    .opcodepreRR1(opcodepreRR1),
    .opcodepreRR2(opcodepreRR2),
    .depend(depend)
);

RR RR0(
    .clk(clk),
    .rst(rst),
    .dstregpreRR1(dstregpreRR1),
    .dstregpreRR2(dstregpreRR2),
    .preRRpc1(preRRpc1),
    .preRRpc2(preRRpc2),
    .w_addrRW1(dstregRW1),
    .wb_dataRW1(wb_dataRW1),
    .w_addrRW2(dstregRW2),
    .wb_dataRW2(wb_dataRW2),
    .wb_enRW1(wb_enRW1),
    .wb_enRW2(wb_enRW2),
    .reg_wepreRR1(reg_wepreRR1),
    .reg_wepreRR2(reg_wepreRR2),
    .immpreRR1(immpreRR1),
    .immpreRR2(immpreRR2),
    .is_loadpreRR1(is_loadpreRR1),
    .is_loadpreRR2(is_loadpreRR2),
    .is_storepreRR1(is_storepreRR1),
    .is_storepreRR2(is_storepreRR2),
    .alucodepreRR1(alucodepreRR1),
    .alucodepreRR2(alucodepreRR2),
    .aluop1_typepreRR1(aluop1_typepreRR1),
    .aluop2_typepreRR1(aluop2_typepreRR1),
    .aluop1_typepreRR2(aluop1_typepreRR2),
    .aluop2_typepreRR2(aluop2_typepreRR2),
    .srcreg11(srcreg11),
    .srcreg12(srcreg12),
    .srcreg21(srcreg21),
    .srcreg22(srcreg22),
    .funct3preRR1(funct3preRR1),
    .funct3preRR2(funct3preRR2),
    .opcodepreRR1(opcodepreRR1),
    .opcodepreRR2(opcodepreRR2),
    .fail(fail),
    .prePC1(prePC1),
    .prePC2(prePC2),
    .r_data1RR1(r_data1RR1),
    .r_data2RR1(r_data2RR1),
    .r_data1RR2(r_data1RR2),
    .r_data2RR2(r_data2RR2),
    .dstregRR1(dstregRR1),
    .dstregRR2(dstregRR2),
    .immRR1(immRR1),
    .immRR2(immRR2),
    .alucodeRR1(alucodeRR1),
    .alucodeRR2(alucodeRR2),
    .aluop1_typeRR1(aluop1_typeRR1),
    .aluop2_typeRR1(aluop2_typeRR1),
    .aluop1_typeRR2(aluop1_typeRR2),
    .aluop2_typeRR2(aluop2_typeRR2),
    .reg_weRR1(reg_weRR1),
    .reg_weRR2(reg_weRR2),
    .is_loadRR1(is_loadRR1),
    .is_loadRR2(is_loadRR2),
    .is_storeRR1(is_storeRR1),
    .is_storeRR2(is_storeRR2),
    .RRpc1(RRpc1),
    .RRpc2(RRpc2),
    .srcreg11RR(srcreg11RR),
    .srcreg12RR(srcreg12RR),
    .srcreg21RR(srcreg21RR),
    .srcreg22RR(srcreg22RR),
    .funct3RR1(funct3RR1),
    .funct3RR2(funct3RR2),
    .prePCRR1(prePCRR1),
    .prePCRR2(prePCRR2),
    .opcodeRR1(opcodeRR1),
    .opcodeRR2(opcodeRR2)
);

EX EX0(
    .clk(clk),
    .rst(rst),
    .r_dataRR11(r_data1RR1),
    .r_dataRR12(r_data2RR1),
    .r_dataRR21(r_data1RR2),
    .r_dataRR22(r_data2RR2),
    .opcodeRR1(opcodeRR1),
    .opcodeRR2(opcodeRR2),
    .dstregRR1(dstregRR1),
    .dstregRR2(dstregRR2),
    .immRR1(immRR1),
    .immRR2(immRR2),
    .alucodeRR1(alucodeRR1),
    .alucodeRR2(alucodeRR2),
    .aluop1_typeRR1(aluop1_typeRR1),
    .aluop2_typeRR1(aluop2_typeRR1),
    .aluop1_typeRR2(aluop1_typeRR2),
    .aluop2_typeRR2(aluop2_typeRR2),
    .funct3RR1(funct3RR1),
    .funct3RR2(funct3RR2),
    .loadvalue_wordMA1(loadvalue_wordMA1),
    .loadvalue_wordMA2(loadvalue_wordMA2),
    .reg_weRR1(reg_weRR1),
    .is_loadRR1(is_loadRR1),
    .is_storeRR1(is_storeRR1),
    .reg_weRR2(reg_weRR2),
    .is_loadRR2(is_loadRR2),
    .is_storeRR2(is_storeRR2),
    .RRpc1(RRpc1),
    .RRpc2(RRpc2),
    .forwarding11(forwarding11),
    .forwarding12(forwarding12),
    .forwarding21(forwarding21),
    .forwarding22(forwarding22),
    .wb_dataRW1(wb_dataRW1),
    .wb_dataRW2(wb_dataRW2),
    .prePCRR1(prePCRR1),
    .prePCRR2(prePCRR2),
    .aluresultEX1(aluresultEX1),
    .aluresultEX2(aluresultEX2),
    .write_addressEX1(write_addressEX1),
    .write_addressEX2(write_addressEX2),
    .read_addressEX1(read_addressEX1),
    .read_addressEX2(read_addressEX2),
    .storevalue_wordEX1(storevalue_wordEX1),
    .storevalue_wordEX2(storevalue_wordEX2),
    .write_en_bmEX1(write_en_bmEX1),
    .write_en_bmEX2(write_en_bmEX2),
    .dstregEX1(dstregEX1),
    .dstregEX2(dstregEX2),
    .dstregMA1(dstregMA1),
    .dstregMA2(dstregMA2),
    .reg_weEX1(reg_weEX1),
    .is_loadEX1(is_loadEX1),
    .is_storeEX1(is_storeEX1),
    .reg_weEX2(reg_weEX2),
    .is_loadEX2(is_loadEX2),
    .is_storeEX2(is_storeEX2),
    .is_jump1(is_jump1),
    .is_jump2(is_jump2),
    .jump_pc(jump_pc),
    .load_reg_valueMA1(load_reg_valueMA1),
    .load_reg_valueMA2(load_reg_valueMA2),
    .reg_weMA1(reg_weMA1),
    .reg_weMA2(reg_weMA2),
    .aluresultMA1(aluresultMA1),
    .aluresultMA2(aluresultMA2),
    .is_loadMA1(is_loadMA1),
    .is_loadMA2(is_loadMA2),
    .fail(fail),

    .r_data12(r_data12),
    .r_data22(r_data22)
);

MA MA0(
    .clk(clk),
    .rst(rst),
    .write_en_bmEX1(write_en_bmEX1),
    .write_en_bmEX2(write_en_bmEX2),
    .read_addressEX1(read_addressEX1),
    .read_addressEX2(read_addressEX2),
    .write_addressEX1(write_addressEX1),
    .write_addressEX2(write_addressEX2),
    .storevalue_wordEX1(storevalue_wordEX1),
    .storevalue_wordEX2(storevalue_wordEX2),
    .is_hw_count1(is_hw_count1),
    .is_hw_count2(is_hw_count2),
    .hc_OUT_data(hc_OUT_data),
    .loadvalue_wordMA1(loadvalue_wordMA1),
    .loadvalue_wordMA2(loadvalue_wordMA2)
);
// 同時書き込み防止が必要
RW RW0(
    .is_loadMA1(is_loadMA1),
    .is_loadMA2(is_loadMA2),
    .aluresultMA1(aluresultMA1),
    .aluresultMA2(aluresultMA2),
    .load_reg_valueMA1(load_reg_valueMA1),
    .load_reg_valueMA2(load_reg_valueMA2),
    .dstregMA1(dstregMA1),
    .dstregMA2(dstregMA2),
    .reg_weMA1(reg_weMA1),
    .reg_weMA2(reg_weMA2),
    .wb_dataRW1(wb_dataRW1),
    .wb_dataRW2(wb_dataRW2),
    .dstregRW1(dstregRW1),
    .dstregRW2(dstregRW2),
    .wb_enRW1(wb_enRW1),
    .wb_enRW2(wb_enRW2)
);

forwarding_unit forwarding_unit0(
    .dstregEX1(dstregEX1),
    .dstregEX2(dstregEX2),
    .dstregMA1(dstregMA1),
    .dstregMA2(dstregMA2),
    .srcreg11_num(srcreg11RR),
    .srcreg12_num(srcreg12RR),
    .srcreg21_num(srcreg21RR),
    .srcreg22_num(srcreg22RR),
    .reg_weEX1(reg_weEX1),
    .reg_weEX2(reg_weEX2),
    .reg_weMA1(reg_weMA1),
    .reg_weMA2(reg_weMA2),
    .forwarding11(forwarding11),
    .forwarding12(forwarding12),
    .forwarding21(forwarding21),
    .forwarding22(forwarding22)
);

hardware_counter hardware_counter0(
    .CLK_IP(clk),
    .RSTN_IP(rst),
    .COUNTER_OP(hc_OUT_data)
);

uart uart0(
    .uart_tx(uart_OUT_data),
    .uart_wr_i(uart_we),
    .uart_dat_i(uart_IN_data),
    .sys_clk_i(clk),
    .sys_rstn_i(rst)
);

reg [31:0] irpreRR1, irRR1, irEX1, irMA1;
reg [31:0] EXpc1, MApc1;
reg [31:0] read_addressMA1, write_addressMA1, storevalue_wordMA1;
reg is_storeMA1;
reg [5:0] alucodeEX1, alucodeMA1;
reg [31:0] r_data2EX1, r_data2MA1;

reg [31:0] irpreRR2, irRR2, irEX2, irMA2;
reg [31:0] EXpc2, MApc2;
reg [31:0] read_addressMA2, write_addressMA2, storevalue_wordMA2;
reg is_storeMA2;
reg [5:0] alucodeEX2, alucodeMA2;
reg [31:0] r_data2EX2, r_data2MA2;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc <= 32'h8000;

        irpreRR1 <= 32'd0;
        irRR1 <= 32'd0;;
        irEX1 <= 32'd0;
        irMA1 <= 32'd0;
        EXpc1 <= 32'd0;
        MApc1 <= 32'd0;
        read_addressMA1<=32'd0;
        write_addressMA1 <= 32'd0;
        storevalue_wordMA1 <= 32'd0;
        is_storeMA1 <= 1'd0;
        alucodeEX1 <= 6'd0;
        alucodeMA1 <= 6'd0;
        r_data2MA1 <= 32'd0;
        r_data2EX1 <= 32'd0;

        irpreRR2 <= 32'd0;
        irRR2 <= 32'd0;;
        irEX2 <= 32'd0;
        irMA2 <= 32'd0;
        EXpc2 <= 32'd0;
        MApc2 <= 32'd0;
        read_addressMA2 <=32'd0;
        write_addressMA2 <= 32'd0;
        storevalue_wordMA2 <= 32'd0;
        is_storeMA2 <= 1'd0;
        alucodeEX2 <= 6'd0;
        alucodeMA2 <= 6'd0;
        r_data2MA2 <= 32'd0;
        r_data2EX2 <= 32'd0;
        */
    end
    else begin
        pc <= npc;

        irpreRR1 <= ir1;
        irRR1 <= irpreRR1;
        irEX1 <= irRR1;
        irMA1 <= irEX1;
        EXpc1 <= RRpc1;
        MApc1 <= EXpc1;
        read_addressMA1 <= read_addressEX1;
        write_addressMA1 <= write_addressEX1;
        storevalue_wordMA1 <=storevalue_wordEX1;
        is_storeMA1 <= is_storeEX1;
        alucodeEX1 <= alucodeRR1;
        alucodeMA1 <= alucodeEX1;
        r_data2MA1 <= r_data2EX1;
        r_data2EX1 <= r_data12;

        irpreRR2 <= ir2;
        irRR2 <= irpreRR2;
        irEX2 <= irRR2;
        irMA2 <= irEX2;
        EXpc2 <= RRpc2;
        MApc2 <= EXpc2;
        read_addressMA2 <= read_addressEX2;
        write_addressMA2 <= write_addressEX2;
        storevalue_wordMA2 <=storevalue_wordEX2;
        is_storeMA2 <= is_storeEX2;
        alucodeEX2 <= alucodeRR2;
        alucodeMA2 <= alucodeEX2;
        r_data2MA2 <= r_data2EX2;
        r_data2EX2 <= r_data22;
        */
    end

    if (irMA1!=0 && MApc1!=0) begin
        if (is_loadMA1) begin
            if (alucodeMA1 == `ALU_LW) $display("0x%h: 0x%h # x%02d = 0x%h;      0x%h <- mem[0x%h]",MApc1[15:0], irMA1, dstregRW1,wb_dataRW1,load_reg_valueMA1, read_addressMA1);
            if (alucodeMA1 == `ALU_LH || alucodeMA1 == `ALU_LHU) $display("0x%h: 0x%h # x%02d = 0x%h;          0x%h <- mem[0x%h]",MApc1[15:0], irMA1, dstregRW1, wb_dataRW1, load_reg_valueMA1[15:0], read_addressMA1);
            if (alucodeMA1 == `ALU_LB || alucodeMA1 == `ALU_LBU) $display("0x%h: 0x%h # x%02d = 0x%h;            0x%h <- mem[0x%h]",MApc1[15:0], irMA1, dstregRW1, wb_dataRW1, load_reg_valueMA1[7:0], read_addressMA1);
        end
        else if (dstregRW1!=0) $display("0x%h: 0x%h # x%02d = 0x%h",MApc1[15:0], irMA1, dstregRW1,wb_dataRW1);
        else if (is_storeMA1 && write_addressMA1!=0) begin
            if (alucodeMA1 == `ALU_SW) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc1[15:0], irMA1, write_addressMA1, storevalue_wordMA1);
            if (alucodeMA1 == `ALU_SH) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc1[15:0], irMA1, write_addressMA1, r_data2MA1[15:0]);
            if (alucodeMA1 == `ALU_SB) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc1[15:0], irMA1, write_addressMA1, r_data2MA1[7:0]);
           end
        else $display("0x%h: 0x%h # (no destination)",MApc1[15:0], irMA1);

    end

    if (irMA2!=0 && MApc2!=0) begin
        if (is_loadMA2) begin
            if (alucodeMA2 == `ALU_LW) $display("0x%h: 0x%h # x%02d = 0x%h;      0x%h <- mem[0x%h]",MApc2[15:0], irMA2, dstregRW2,wb_dataRW2, load_reg_valueMA2, read_addressMA2);
            if (alucodeMA2 == `ALU_LH || alucodeMA2 == `ALU_LHU) $display("0x%h: 0x%h # x%02d = 0x%h;          0x%h <- mem[0x%h]",MApc2[15:0], irMA2, dstregRW2, wb_dataRW2, load_reg_valueMA2[15:0], read_addressMA2);
            if (alucodeMA2 == `ALU_LB || alucodeMA2 == `ALU_LBU) $display("0x%h: 0x%h # x%02d = 0x%h;            0x%h <- mem[0x%h]",MApc2[15:0], irMA2, dstregRW2, wb_dataRW2, load_reg_valueMA2[7:0], read_addressMA2);
        end
        else if (dstregRW2!=0) $display("0x%h: 0x%h # x%02d = 0x%h",MApc2[15:0], irMA2, dstregRW2,wb_dataRW2);
        else if (is_storeMA2 && write_addressMA2!=0) begin
            if (alucodeMA2 == `ALU_SW) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc2[15:0], irMA2, write_addressMA2, storevalue_wordMA2);
            if (alucodeMA2 == `ALU_SH) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc2[15:0], irMA2, write_addressMA2, r_data2MA2[15:0]);
            if (alucodeMA2 == `ALU_SB) $display("0x%h: 0x%h # (no destination); mem[0x%h] <- 0x%h",MApc2[15:0], irMA2, write_addressMA2, r_data2MA2[7:0]);
        end
        else $display("0x%h: 0x%h # (no destination)",MApc2[15:0], irMA2);
    end

end

endmodule
