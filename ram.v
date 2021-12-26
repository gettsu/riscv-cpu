`include "define.vh"
module ram(
    input wire clk,
    input wire [3:0] we1, we2, 
    input wire [31:0] r_addr1, w_addr1,r_addr2, w_addr2,
    input wire [31:0] w_data1, w_data2,
    output wire [31:0] r_data1, r_data2
);

reg [7:0] mem [0:32768];
initial $readmemh("/home/denjo/experiment/b3exp/benchmarks/Coremark_for_Synthesis/data.hex", mem);
wire [31:0] w_num1, w_num2,  r_num1, r_num2;
assign w_num1 = {{2{1'b0}},w_addr1[31:2]};
assign w_num2 = {{2{1'b0}},w_addr2[31:2]};
assign r_num1 = {{2{1'b0}},r_addr1[31:2]};
assign r_num2 = {{2{1'b0}},r_addr2[31:2]};

always @(posedge clk) begin
    if(we1[0]) mem[w_num1][ 7: 0] <= w_data1[ 7: 0];
    if(we1[1]) mem[w_num1][15: 8] <= w_data1[15: 8];
    if(we1[2]) mem[w_num1][23:16] <= w_data1[23:16];
    if(we1[3]) mem[w_num1][31:24] <= w_data1[31:24];
    r_data1 <= mem[r_num1];
end
always @(posedge clk) begin
    if(we2[0]) mem[w_num2][ 7: 0] <= w_data2[ 7: 0];
    if(we2[1]) mem[w_num2][15: 8] <= w_data2[15: 8];
    if(we2[2]) mem[w_num2][23:16] <= w_data2[23:16];
    if(we2[3]) mem[w_num2][31:24] <= w_data2[31:24];
    r_data2 <= mem[r_num2];
end

endmodule
 