module RW(
    input wire is_loadMA1,
    input wire is_loadMA2,
    input wire [31:0] aluresultMA1, aluresultMA2,
    input wire [31:0] load_reg_valueMA1, load_reg_valueMA2,
    input wire [4:0] dstregMA1, dstregMA2,
    input wire reg_weMA1, reg_weMA2,
    output wire [31:0] wb_dataRW1, wb_dataRW2,
    output wire [4:0] dstregRW1, dstregRW2,
    output wire wb_enRW1, wb_enRW2
);

wb_switch wb_switch0(
    .is_load(is_loadMA1),
    .load_reg_value(load_reg_valueMA1),
    .alu_result(aluresultMA1),
    .wb_data(wb_dataRW1)
);

wb_switch wb_switch1(
    .is_load(is_loadMA2),
    .load_reg_value(load_reg_valueMA2),
    .alu_result(aluresultMA2),
    .wb_data(wb_dataRW2)
);

assign dstregRW1 = dstregMA1;
assign dstregRW2 = dstregMA2;
assign wb_enRW1 = reg_weMA1;
assign wb_enRW2 = reg_weMA2;

endmodule

