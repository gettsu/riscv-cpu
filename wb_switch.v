`include "define.vh"
module wb_switch(
    input wire is_load,
    input wire [31:0] load_reg_value,
    input wire [31:0] alu_result,
    output wire [31:0] wb_data
);

assign wb_data = (is_load == `ENABLE) ? load_reg_value : alu_result;
endmodule