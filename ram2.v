`include "define.vh"
module ram2(
    input wire clk,
    input wire we1, we2, 
    input wire [31:0] rw_num1, rw_num2,
    input wire [7:0] w_data1, w_data2,
    output reg [7:0] r_data1, r_data2
);

reg [7:0] mem [0:32768];
initial $readmemh("/home/denjo/experiment/riscv-exp/data2.hex", mem);

always @(posedge clk) begin
    if(we1) mem[rw_num1] <= w_data1;
    r_data1 <= mem[rw_num1];
end
always @(posedge clk) begin
    if(we2) mem[rw_num2] <= w_data2;
    r_data2 <= mem[rw_num2];
end

endmodule