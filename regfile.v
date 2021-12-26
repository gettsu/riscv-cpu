//分散ram
module regfile(
    input wire clk, we1, we2,
    input wire[4:0] r_addr11, r_addr12, r_addr21, r_addr22, w_addr1, w_addr2,
    input wire [31:0] w_data1, w_data2,
    output wire [31:0] r_data11, r_data12, r_data21, r_data22
);
reg [31:0] mema [0:31];             //32bitのレジスタが32個(アドレスは5bit)
reg [31:0] memb [0:31];

initial mema[0] = 0;
initial memb[0] = 0;

always @(posedge clk) begin
    if (we1) mema[w_addr1] <= w_data1 ^ memb[w_addr1]; //クロックと同期して書き込まれる
    if (we2) memb[w_addr2] <= w_data2 ^ mema[w_addr2];
end
assign r_data11 = mema[r_addr11] ^ memb[r_addr11];
assign r_data12 = mema[r_addr12] ^ memb[r_addr12];
assign r_data21 = mema[r_addr21] ^ memb[r_addr21];
assign r_data22 = mema[r_addr22] ^ memb[r_addr22];

endmodule
