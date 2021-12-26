//
// decoder_tb
//
`define assert(name, signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %s : signal is '%d' but expected '%d'", name, signal, value); \
            $finish; \
        end else begin \
            $display("\t%m: signal == value"); \
        end

`define test(name, ir, ex_srcreg1_num, ex_srcreg2_num, ex_dstreg_num, ex_imm, ex_alucode, ex_aluop1_type, ex_aluop2_type, ex_reg_we, ex_is_load, ex_is_store, ex_is_halt) \
        $display("%s:", name); \
        $display("\tcodeword: %b", ir); \
        `assert("srcreg1_num", srcreg1_num, ex_srcreg1_num) \
        `assert("srcreg2_num", srcreg2_num, ex_srcreg2_num) \
        `assert("dstreg_num", dstreg_num, ex_dstreg_num) \
        `assert("imm", imm, ex_imm) \
        `assert("alucode", alucode, ex_alucode) \
        `assert("aluop1_type", aluop1_type, ex_aluop1_type) \
        `assert("aluop2_type", aluop2_type, ex_aluop2_type) \
        `assert("reg_we", reg_we, ex_reg_we) \
        `assert("is_load", is_load, ex_is_load) \
        `assert("is_store", is_store, ex_is_store) \
        $display("%s test ...ok\n", name); \

`include "define.vh"

module decoder_tb;
    reg [31:0] ir;
    wire [4:0] srcreg1_num;
    wire [4:0] srcreg2_num;
    wire [4:0] dstreg_num;
    wire [31:0] imm;
    wire [5:0] alucode;
    wire [1:0] aluop1_type;
    wire [1:0] aluop2_type;
    wire reg_we;
    wire is_load;
    wire is_store;
    wire is_halt;

    decoder decoder(
        .ir(ir),
        .srcreg1_num(srcreg1_num),
        .srcreg2_num(srcreg2_num),
        .dstreg_num(dstreg_num),
        .imm(imm),
        .alucode(alucode),
        .aluop1_type(aluop1_type),
        .aluop2_type(aluop2_type),
        .reg_we(reg_we),
        .is_load(is_load),
        .is_store(is_store),
        .is_halt(is_halt)
    );



    initial begin

        // --------------------------------------- //
        // tworeg
        // --------------------------------------- //

        // 32'hb50633 ADD [10, 11] [12] 0
        ir = 32'hb50633; #10;
        `test("ADD", ir, 10, 11, 12, 0, `ALU_ADD, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h40b60633 SUB [12, 11] [12] 0
        ir = 32'h40b60633; #10;
        `test("SUB", ir, 12, 11, 12, 0, `ALU_SUB, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h11626b3 SLT [12, 17] [13] 0
        ir = 32'h11626b3; #10;
        `test("SLT", ir, 12, 17, 13, 0, `ALU_SLT, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc5b6b3 SLTU [11, 12] [13] 0
        ir = 32'hc5b6b3; #10;
        `test("SLTU", ir, 11, 12, 13, 0, `ALU_SLTU, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hb57733 AND [10, 11] [14] 0
        ir = 32'hb57733; #10;
        `test("AND", ir, 10, 11, 14, 0, `ALU_AND, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc8e733 OR [17, 12] [14] 0
        ir = 32'hc8e733; #10;
        `test("OR", ir, 17, 12, 14, 0, `ALU_OR, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc8c733 XOR [17, 12] [14] 0
        ir = 32'hc8c733; #10;
        `test("XOR", ir, 17, 12, 14, 0, `ALU_XOR, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc597b3 SLL [11, 12] [15] 0
        ir = 32'hc597b3; #10;
        `test("SLL", ir, 11, 12, 15, 0, `ALU_SLL, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hb657b3 SRL [12, 11] [15] 0
        ir = 32'hb657b3; #10;
        `test("SRL", ir, 12, 11, 15, 0, `ALU_SRL, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h40b5d7b3 SRA [11, 11] [15] 0
        ir = 32'h40b5d7b3; #10;
        `test("SRA", ir, 11, 11, 15, 0, `ALU_SRA, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)


        // --------------------------------------- //
        // onereg
        // --------------------------------------- //

        // 32'hfff00513 ADDI [0] [10] -1
        ir = 32'hfff00513; #10;
        `test("ADDI", ir, 0, 0, 10, 32'hffffffff, `ALU_ADD, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h150593 ADDI [10] [11] 1
        ir = 32'h150593; #10;
        `test("ADDI", ir, 10, 0, 11, 1, `ALU_ADD, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h5a613 SLTI [11] [12] 0
        ir = 32'h5a613; #10;
        `test("SLTI", ir, 11, 0, 12, 0, `ALU_SLT, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfff5a613 SLTI [11] [12] -1
        ir = 32'hfff5a613; #10;
        `test("SLTI", ir, 11, 0, 12, -1, `ALU_SLT, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h5b693 SLTIU [11] [13] 0
        ir = 32'h5b693; #10;
        `test("SLTIU", ir, 11, 0, 13, 0, `ALU_SLTU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfff5b693 SLTIU [11] [13] -1
        ir = 32'hfff5b693; #10;
        `test("SLTIU", ir, 11, 0, 13, -1, `ALU_SLTU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h15f713 ANDI [11] [14] 1
        ir = 32'h15f713; #10;
        `test("ANDI", ir, 11, 0, 14, 1, `ALU_AND, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfff5f713 ANDI [11] [14] -1
        ir = 32'hfff5f713; #10;
        `test("ANDI", ir, 11, 0, 14, -1, `ALU_AND, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h5e713 ORI [11] [14] 0
        ir = 32'h5e713; #10;
        `test("ORI", ir, 11, 0, 14, 0, `ALU_OR, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfff6e713 ORI [13] [14] -1
        ir = 32'hfff6e713; #10;
        `test("ORI", ir, 13, 0, 14, -1, `ALU_OR, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h5c713 XORI [11] [14] 0
        ir = 32'h5c713; #10;
        `test("XORI", ir, 11, 0, 14, 0, `ALU_XOR, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfff5c713 XORI [11] [14] -1
        ir = 32'hfff5c713; #10;
        `test("XORI", ir, 11, 0, 14, -1, `ALU_XOR, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h279793 SLLI [15] [15] 2
        ir = 32'h279793; #10;
        `test("SLLI", ir, 15, 0, 15, 2, `ALU_SLL, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h17d793 SRLI [15] [15] 1
        ir = 32'h17d793; #10;
        `test("SRLI", ir, 15, 0, 15, 1, `ALU_SRL, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h15d793 SRLI [11] [15] 1
        ir = 32'h15d793; #10;
        `test("SRLI", ir, 11, 0, 15, 1, `ALU_SRL, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h4015d793 SRAI [11] [15] 1
        ir = 32'h4015d793; #10;
        `test("SRAI", ir, 11, 0, 15, 1, `ALU_SRA, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h1837 LUI [] [16] 1
        ir = 32'h1837; #10;
        `test("LUI", ir, 0, 0, 16, 4096, `ALU_LUI, `OP_TYPE_NONE, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h808805b7 LUI [] [11] -522112
        ir = 32'h808805b7; #10;
        `test("LUI", ir, 0, 0, 11, 2156396544, `ALU_LUI, `OP_TYPE_NONE, `OP_TYPE_IMM, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h817 AUIPC [] [16] 0
        ir = 32'h817; #10;
        `test("AUIPC", ir, 0, 0, 16, 0, `ALU_ADD, `OP_TYPE_IMM, `OP_TYPE_PC, `ENABLE, `DISABLE, `DISABLE, `DISABLE)


        // --------------------------------------- //
        // memaccess
        // --------------------------------------- //

        // 32'hb52023 SW [10, 11] [] 0
        ir = 32'hb52023; #10;
        `test("SW", ir, 10, 11, 0, 0, `ALU_SW, `OP_TYPE_REG, `OP_TYPE_IMM, `DISABLE, `DISABLE, `ENABLE, `DISABLE)

        // 32'hb51023 SH [10, 11] [] 0
        ir = 32'hb51023; #10;
        `test("SH", ir, 10, 11, 0, 0, `ALU_SH, `OP_TYPE_REG, `OP_TYPE_IMM, `DISABLE, `DISABLE, `ENABLE, `DISABLE)

        // 32'hb510a3 SH [10, 11] [] 1
        ir = 32'hb510a3; #10;
        `test("SH", ir, 10, 11, 0, 1, `ALU_SH, `OP_TYPE_REG, `OP_TYPE_IMM, `DISABLE, `DISABLE, `ENABLE, `DISABLE)

        // 32'hb50023 SB [10, 11] [] 0
        ir = 32'hb50023; #10;
        `test("SB", ir, 10, 11, 0, 0, `ALU_SB, `OP_TYPE_REG, `OP_TYPE_IMM, `DISABLE, `DISABLE, `ENABLE, `DISABLE)

        // 32'hb500a3 SB [10, 11] [] 1
        ir = 32'hb500a3; #10;
        `test("SB", ir, 10, 11, 0, 1, `ALU_SB, `OP_TYPE_REG, `OP_TYPE_IMM, `DISABLE, `DISABLE, `ENABLE, `DISABLE)

        // 32'h52683 LW [10] [13] 0
        ir = 32'h52683; #10;
        `test("LW", ir, 10, 0, 13, 0, `ALU_LW, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h51683 LH [10] [13] 0
        ir = 32'h51683; #10;
        `test("LH", ir, 10, 0, 13, 0, `ALU_LH, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h251683 LH [10] [13] 2
        ir = 32'h251683; #10;
        `test("LH", ir, 10, 0, 13, 2, `ALU_LH, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h250683 LB [10] [13] 2
        ir = 32'h250683; #10;
        `test("LB", ir, 10, 0, 13, 2, `ALU_LB, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h350683 LB [10] [13] 3
        ir = 32'h350683; #10;
        `test("LB", ir, 10, 0, 13, 3, `ALU_LB, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h55683 LHU [10] [13] 0
        ir = 32'h55683; #10;
        `test("LHU", ir, 10, 0, 13, 0, `ALU_LHU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h155683 LHU [10] [13] 1
        ir = 32'h155683; #10;
        `test("LHU", ir, 10, 0, 13, 1, `ALU_LHU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h255683 LHU [10] [13] 2
        ir = 32'h255683; #10;
        `test("LHU", ir, 10, 0, 13, 2, `ALU_LHU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h154683 LBU [10] [13] 1
        ir = 32'h154683; #10;
        `test("LBU", ir, 10, 0, 13, 1, `ALU_LBU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h254683 LBU [10] [13] 2
        ir = 32'h254683; #10;
        `test("LBU", ir, 10, 0, 13, 2, `ALU_LBU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)

        // 32'h354683 LBU [10] [13] 3
        ir = 32'h354683; #10;
        `test("LBU", ir, 10, 0, 13, 3, `ALU_LBU, `OP_TYPE_REG, `OP_TYPE_IMM, `ENABLE, `ENABLE, `DISABLE, `DISABLE)


        // --------------------------------------- //
        // branch
        // --------------------------------------- //

        // 32'hfec584e3 BEQ [11, 12] [] -24
        ir = 32'hfec584e3; #10;
        `test("BEQ", ir, 11, 12, 0, -24, `ALU_BEQ, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hd60463 BEQ [12, 13] [] 8
        ir = 32'hd60463; #10;
        `test("BEQ", ir, 12, 13, 0, 8, `ALU_BEQ, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfcd61ce3 BNE [12, 13] [] -40
        ir = 32'hfcd61ce3; #10;
        `test("BNE", ir, 12, 13, 0, -40, `ALU_BNE, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc59463 BNE [11, 12] [] 8
        ir = 32'hc59463; #10;
        `test("BNE", ir, 11, 12, 0, 8, `ALU_BNE, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfcd644e3 BLT [12, 13] [] -56
        ir = 32'hfcd644e3; #10;
        `test("BLT", ir, 12, 13, 0, -56, `ALU_BLT, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfce542e3 BLT [10, 14] [] -60
        ir = 32'hfce542e3; #10;
        `test("BLT", ir, 10, 14, 0, -60, `ALU_BLT, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'ha74463 BLT [14, 10] [] 8
        ir = 32'ha74463; #10;
        `test("BLT", ir, 14, 10, 0, 8, `ALU_BLT, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hfaa75ae3 BGE [14, 10] [] -76
        ir = 32'hfaa75ae3; #10;
        `test("BGE", ir, 14, 10, 0, -76, `ALU_BGE, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'he55463 BGE [10, 14] [] 8
        ir = 32'he55463; #10;
        `test("BGE", ir, 10, 14, 0, 8, `ALU_BGE, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hd65463 BGE [12, 13] [] 8
        ir = 32'hd65463; #10;
        `test("BGE", ir, 12, 13, 0, 8, `ALU_BGE, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hf8d66ce3 BLTU [12, 13] [] -104
        ir = 32'hf8d66ce3; #10;
        `test("BLTU", ir, 12, 13, 0, -104, `ALU_BLTU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hf8a76ae3 BLTU [14, 10] [] -108
        ir = 32'hf8a76ae3; #10;
        `test("BLTU", ir, 14, 10, 0, -108, `ALU_BLTU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'he56463 BLTU [10, 14] [] 8
        ir = 32'he56463; #10;
        `test("BLTU", ir, 10, 14, 0, 8, `ALU_BLTU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hf8e572e3 BGEU [10, 14] [] -124
        ir = 32'hf8e572e3; #10;
        `test("BGEU", ir, 10, 14, 0, -124, `ALU_BGEU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'ha77463 BGEU [14, 10] [] 8
        ir = 32'ha77463; #10;
        `test("BGEU", ir, 14, 10, 0, 8, `ALU_BGEU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hd67463 BGEU [12, 13] [] 8
        ir = 32'hd67463; #10;
        `test("BGEU", ir, 12, 13, 0, 8, `ALU_BGEU, `OP_TYPE_REG, `OP_TYPE_REG, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h8000ef JAL [] [1] 8
        ir = 32'h8000ef; #10;
        `test("JAL", ir, 0, 0, 1, 8, `ALU_JAL, `OP_TYPE_NONE, `OP_TYPE_PC, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc0006f JAL [] [0] 12
        ir = 32'hc0006f; #10;
        `test("JAL", ir, 0, 0, 0, 12, `ALU_JAL, `OP_TYPE_NONE, `OP_TYPE_PC, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h8005ef JAL [] [11] 8
        ir = 32'h8005ef; #10;
        `test("JAL", ir, 0, 0, 11, 8, `ALU_JAL, `OP_TYPE_NONE, `OP_TYPE_PC, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'h8580e7 JALR [11] [1] 8
        ir = 32'h8580e7; #10;
        `test("JALR", ir, 11, 0, 1, 8, `ALU_JALR, `OP_TYPE_REG, `OP_TYPE_PC, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

        // 32'hc08067 JALR [1] [0] 12
        ir = 32'hc08067; #10;
        `test("JALR", ir, 1, 0, 0, 12, `ALU_JALR, `OP_TYPE_REG, `OP_TYPE_PC, `DISABLE, `DISABLE, `DISABLE, `DISABLE)

        $display("all decoder-tests passed!");
    end

endmodule