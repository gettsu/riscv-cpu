`include "define.vh"
module MA(
    input wire clk,
    input wire rst,
    input wire [3:0] write_en_bmEX1,
    input wire [3:0] write_en_bmEX2,
    input wire [31:0] read_addressEX1,
    input wire [31:0] read_addressEX2,
    input wire [31:0] write_addressEX1,
    input wire [31:0] write_addressEX2,
    input wire [31:0] storevalue_wordEX1,
    input wire [31:0] storevalue_wordEX2,
    input wire is_hw_count1,
    input wire is_hw_count2,
    input wire [31:0] hc_OUT_data,
    output wire [31:0] loadvalue_wordMA1,
    output wire [31:0] loadvalue_wordMA2
);
wire [31:0] r_addr1, r_addr2;
assign r_addr1 = is_hw_count1 ? 32'd0 : read_addressEX1;
assign r_addr2 = is_hw_count2 ? 32'd0 : read_addressEX2;

wire [31:0] loadvalue_word1, loadvalue_word2;

reg hw_count1, hw_count2;
reg [31:0] hc_OUT_datar;
reg [31:0] write_address1, read_address2;
reg [31:0] write_data1;

wire [3:0] we1, we2;
assign we1 = ((write_addressEX1 == `UART_ADDR) | (write_addressEX1 == write_addressEX2)) ? 4'd0 : write_en_bmEX1;
assign we2 = (write_addressEX2 == `UART_ADDR) ? 4'd0 : write_en_bmEX2;

wire [31:0] write_addr1, write_addr2;
assign write_addr1 = (write_addressEX1 == `UART_ADDR) ? 32'd0 : write_addressEX1;
assign write_addr2 = (write_addressEX2 == `UART_ADDR) ? 32'd0 : write_addressEX2;

wire [31:0] w_num1, w_num2,  r_num1, r_num2;
assign w_num1 = {{2{1'b0}},write_addr1[31:2]};
assign w_num2 = {{2{1'b0}},write_addr2[31:2]};
assign r_num1 = {{2{1'b0}},r_addr1[31:2]};
assign r_num2 = {{2{1'b0}},r_addr2[31:2]};

wire [31:0] rw_num1, rw_num2;
assign rw_num1 = (|we1)? w_num1 : r_num1;
assign rw_num2 = (|we2)? w_num2 : r_num2;

ram0 ram00(
    .clk(clk),
    .we1(we1[0]),
    .we2(we2[0]),
    .rw_num1(rw_num1),
    .rw_num2(rw_num2),
    .r_data1(loadvalue_word1[7:0]),
    .r_data2(loadvalue_word2[7:0]),
    .w_data1(storevalue_wordEX1[7:0]),
    .w_data2(storevalue_wordEX2[7:0])
);

ram1 ram01(
    .clk(clk),
    .we1(we1[1]),
    .we2(we2[1]),
    .rw_num1(rw_num1),
    .rw_num2(rw_num2),
    .r_data1(loadvalue_word1[15:8]),
    .r_data2(loadvalue_word2[15:8]),
    .w_data1(storevalue_wordEX1[15:8]),
    .w_data2(storevalue_wordEX2[15:8])
);

ram2 ram02(
    .clk(clk),
    .we1(we1[2]),
    .we2(we2[2]),
    .rw_num1(rw_num1),
    .rw_num2(rw_num2),
    .r_data1(loadvalue_word1[23:16]),
    .r_data2(loadvalue_word2[23:16]),
    .w_data1(storevalue_wordEX1[23:16]),
    .w_data2(storevalue_wordEX2[23:16])
);

ram3 ram03(
    .clk(clk),
    .we1(we1[3]),
    .we2(we2[3]),
    .rw_num1(rw_num1),
    .rw_num2(rw_num2),
    .r_data1(loadvalue_word1[31:24]),
    .r_data2(loadvalue_word2[31:24]),
    .w_data1(storevalue_wordEX1[31:24]),
    .w_data2(storevalue_wordEX2[31:24])
);

assign loadvalue_wordMA1 = hw_count1 ? hc_OUT_datar : loadvalue_word1;
assign loadvalue_wordMA2 = hw_count2 ? hc_OUT_datar : (write_address1 == read_address2) ? write_data1 : loadvalue_word2;

always @ (posedge clk or negedge rst) begin
    if (!rst) begin
        hw_count1 <= 1'd0;
        hw_count2 <= 1'd0;
        hc_OUT_datar <= 32'd0;
        write_address1 <= 32'd0;
        read_address2 <= 32'd0;
        write_data1 <= 32'd0;
    end
    else begin
        hw_count1 <= is_hw_count1;
        hw_count2 <= is_hw_count2;
        hc_OUT_datar <= hc_OUT_data;
        write_address1 <= write_addressEX1;
        read_address2 <= read_addressEX2;
        write_data1 <= storevalue_wordEX1;
    end
end
endmodule