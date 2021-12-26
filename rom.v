module rom(
    input wire clk,
    input wire rst,
    input wire is_stall,
    input wire depend,
    input wire fail,
    input wire pre_branch1,
    input wire pre_branch2,
    input wire [31:0] r_addr1,
    input wire [31:0] r_addr2,
    output reg [31:0] r_data1,
    output reg [31:0] r_data2
);
reg [31:0] mem[0:65536];

initial $readmemh("/home/denjo/experiment/b3exp/benchmarks/Coremark_for_Synthesis/code.hex", mem);
// initial $readmemh("/home/denjo/experiment/b3exp/benchmarks/tests/LoadAndStore/code.hex", mem);
always @(posedge clk) begin
    if (!rst) begin
        r_data1 <= 32'd0;
        r_data2 <= 32'd0;
    end
    else if (fail) begin
        r_data1 <= 32'd0;
        r_data2 <= 32'd0;
    end
    else if (pre_branch1 && !is_stall) begin
        r_data1 <= 32'd0;
        r_data2 <= 32'd0;
    end
    else if (!is_stall && depend) begin
        r_data1 <= 32'd0;
    end
    else if (pre_branch2 && !is_stall) begin
        r_data1 <= 32'd0;
        r_data2 <= 32'd0;
    end
    else if (!is_stall) begin
        r_data1 <= mem[r_addr1];
        r_data2 <= mem[r_addr2];
    end
end
endmodule
