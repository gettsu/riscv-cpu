//
// alu test bench
//

`define assert(name, signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %s : signal is '0x%x' but expected '0x%x'!", name, signal, value); \
            $finish; \
        end else begin \
            $display("    signal == value"); \
        end

`define test(name, ex_result, ex_br_taken) \
        $display("%s:", name); \
        $display("    code: 0x%x, op1: 0x%x, op2: 0x%x", code, op1, op2); \
        `assert("result", result, ex_result) \
        `assert("br_taken", br, ex_br_taken) \
        $display("%s test passed\n", name); \

`include "define.vh"

module alu_tb;

    reg [5:0] code;
    reg [31:0] op1;
    reg [31:0] op2;
    wire [31:0]  result;
    wire br;

    alu alu(
       .alucode(code),
       .op1(op1),
       .op2(op2),
       .alu_result(result),
       .br_taken(br)
    );

    initial begin

        // -----------------------------
        // arithmetic operations
        // -----------------------------
        
        code = `ALU_ADD;
        op1 = 32'd34;
        op2 = 32'd55;
        #10;
        `test("ALU_ADD", 32'd89, `DISABLE)

        code = `ALU_SUB;
        op1 = 32'd55;
        op2 = 32'd56;
        #10;
        `test("ALU_SUB", 32'hFFFFFFFF, `DISABLE)

        code = `ALU_SLT;
        op1 = 32'hFEEDFACE;
        op2 = 32'hBADCAB1E;
        #10;
        `test("ALU_SLT", 32'h0, `DISABLE)

        code = `ALU_SLTU;
        op1 = 32'hBADCAB1E;
        op2 = 32'hFEEDFACE;
        #10;
        `test("ALU_SLTU", 32'h1, `DISABLE)


        // -----------------------------
        // logical operations
        // -----------------------------
        code = `ALU_XOR;
        op1 = 32'hBADCAB1E;
        op2 = 32'hFEEDFACE;
        #10;
        `test("ALU_XOR", 32'h443151d0, `DISABLE)
        
        code = `ALU_OR;
        op1 = 32'hBADCAB1E;
        op2 = 32'hFEEDFACE;
        #10;
        `test("ALU_OR", 32'hFEFDFBDE, `DISABLE)

        code = `ALU_AND;
        op1 = 32'hBADCAB1E;
        op2 = 32'hFEEDFACE;
        #10;
        `test("ALU_AND", 32'hBACCAA0E, `DISABLE)


        // -----------------------------
        // shift operations
        // -----------------------------
        code = `ALU_SLL;
        op1 = 32'hFEEDFACE;
        op2 = 32'd1036;
        #10;
        `test("ALU_SLL", 32'hDFACE000, `DISABLE)

        code = `ALU_SRL;
        op1 = 32'hDEADDEAD;
        op2 = 32'd16;
        #10;
        `test("ALU_SRL", 32'hDEAD, `DISABLE)

        code = `ALU_SRA;        
        op1 = 32'hDEADDEAD;
        op2 = 32'd16;
        #10;
        `test("ALU_SRA", 32'hFFFFDEAD, `DISABLE)


        // -----------------------------
        // branch/jump operations
        // -----------------------------
        code = `ALU_JAL;
        op1 = 32'hDEADBEEF;
        op2 = 32'h40000;
        #10;
        `test("ALU_JAL", 32'h40004, `ENABLE)

        code = `ALU_JALR;
        op1 = 32'hDEADBEEF;
        op2 = 32'h50000;
        #10;
        `test("ALU_JALR", 32'h50004, `ENABLE)


        code = `ALU_BEQ;
        op1 = 32'hBAADF00D;
        op2 = 32'hBAADCAFE;
        #10;
        `test("ALU_BEQ-1", 32'h0, `DISABLE)
        code = `ALU_BEQ;
        op1 = 32'hBAADF00D;
        op2 = 32'hBAADF00D;
        #10;
        `test("ALU_BEQ-2", 32'h0, `ENABLE)

        code = `ALU_BNE;
        #10;
        op1 = 32'hBAADF00D;
        op2 = 32'hBAADF00D;
        `test("ALU_BNE", 32'h0, `DISABLE)

        code = `ALU_BLT;
        op1 = 32'h100;
        op2 = 32'h123;
        #10;
        `test("ALU_BLT-1", 32'h0, `ENABLE)
        code = `ALU_BLT;
        op1 = 32'h100;
        op2 = 32'hFEE1DEAD;
        #10;
        `test("ALU_BLT-2", 32'h0, `DISABLE)

        code = `ALU_BLTU;
        op1 = 32'h100;
        op2 = 32'hFEE1DEAD;
        #10;
        `test("ALU_BLTU-1", 32'h0, `ENABLE)
        code = `ALU_BLTU;
        op1 = 32'hFFFFFFFF;
        #10;
        `test("ALU_BLTU-2", 32'h0, `DISABLE)
        
        
        code = `ALU_BGE;
        op1 = 32'h100;
        op2 = 32'h123;
        #10;
        `test("ALU_BGE-1", 32'h0, `DISABLE)
        code = `ALU_BGE;
        op1 = 32'h100;
        op2 = 32'hFEE1DEAD;
        #10;
        `test("ALU_BGE-2", 32'h0, `ENABLE)

        code = `ALU_BGEU;
        op1 = 32'h100;
        op2 = 32'hFEE1DEAD;
        #10;
        `test("ALU_BGEU-1", 32'h0, `DISABLE)
        code = `ALU_BGEU;
        op1 = 32'hFFFFFFFF;
        op2 = 32'hFEE1DEAD;
        #10;
        `test("ALU_BGEU-2", 32'h0, `ENABLE)

        // -----------------------------
        // memory operations
        // -----------------------------

        code = `ALU_LB;
        op1 = 32'd1;
        op2 = 32'd1;
        #10;
        `test("ALU_LB", 32'd2, `DISABLE)

        code = `ALU_LH;
        op1 = 32'd1;
        op2 = 32'd2;
        #10;
        `test("ALU_LH", 32'd3, `DISABLE)

        code = `ALU_LW;
        op1 = 32'd2;
        op2 = 32'd3;
        #10;
        `test("ALU_LW", 32'd5, `DISABLE)

        code = `ALU_LBU;
        op1 = 32'd3;
        op2 = 32'd5;
        #10;
        `test("ALU_LBU", 32'd8, `DISABLE)

        code = `ALU_LHU;
        op1 = 32'd5;
        op2 = 32'd8;
        #10;
        `test("ALU_LHU", 32'd13, `DISABLE)

        code = `ALU_SB;
        op1 = 32'd8;
        op2 = 32'd13;
        #10;
        `test("ALU_SB", 32'd21, `DISABLE)

        code = `ALU_SH;
        op1 = 32'd13;
        op2 = 32'd21;
        #10;
        `test("ALU_SH", 32'd34, `DISABLE)

        code = `ALU_SW;
        op1 = 32'd21;
        op2 = 32'd34;
        #10;
        `test("ALU_SW", 32'd55, `DISABLE)


        // -----------------------------
        // other operations
        // -----------------------------
        code = `ALU_LUI;
        op1 = 32'd10;
        op2 = 32'd5054464;
        #10;
        `test("ALU_LUI", 32'd5054464, `DISABLE)

        $display("all ALU-tests passed!");
    end

endmodule