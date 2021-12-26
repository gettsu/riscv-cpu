`include "define.vh"
module lsu(
    input wire [31:0] alu_result,
    input wire [31:0] write_data,
    input wire is_store,
    input wire is_load,
    input wire [2:0] funct3RR,
    input wire [31:0] loadvalue_word,
    input wire [2:0] funct3MA,
    input wire [31:0] read_addressMA,
    output wire [31:0] write_address,
    output wire [31:0] storevalue_word,
    output wire [31:0] read_address,
    output wire [31:0] load_reg_value,
    output wire [3:0] write_en_bm
);
wire [1:0] w_offset, r_offset;

function [3:0] writebm;
    input is_store;
    input [2:0] funct3;
    input [1:0] w_offset;
    begin
        if (is_store == `DISABLE) writebm = 4'd0;
        else begin
            case (funct3)
                3'd0: begin
                    if (w_offset == 2'd0) writebm = 4'd1; 
                    else if (w_offset == 2'd1) writebm = 4'd2;
                    else if (w_offset == 2'd2) writebm = 4'd4;
                    else  writebm = 4'd8;
                end  
                3'd1: begin
                    if (w_offset == 2'd0) writebm = 4'd3;
                    else if (w_offset == 2'd1) writebm = 4'd6;
                    else writebm = 4'd12;
                end
                3'd2: writebm = 4'd15;
                default: writebm = 4'd0;
            endcase
        end
    end
endfunction

function [31:0] stword;
    input is_store;
    input [2:0] funct3;
    input [1:0] w_offset;
    input [31:0] write_data;
    begin
        if (is_store == `DISABLE) stword = 32'd0;
        else begin
            case (funct3)
                3'd0: begin
                    if (w_offset == 2'd0) stword = {{24{1'd0}},write_data[7:0]};
                    else if (w_offset == 2'd1) stword = {{16{1'd0}},write_data[7:0],{8{1'd0}}};
                    else if (w_offset == 2'd2) stword = {{8{1'd0}},write_data[7:0],{16{1'd0}}};
                    else stword = {write_data[7:0],{24{1'd0}}};
                end
                3'd1: begin
                    if (w_offset == 2'd0) stword = {{16{1'd0}},write_data[15:0]};
                    else if (w_offset == 2'd1) stword = {{8{1'd0}},write_data[15:0],{8{1'd0}}};
                    else stword = {write_data[15:0],{16{1'd0}}};
                end
                3'd2: stword = write_data;
                default: stword = 32'd0;
            endcase
        end
    end
endfunction

function [31:0] loadregvalue;
    input [31:0] loadvalue_word;
    input [2:0] funct3;
    input [1:0] r_offset;
    begin
        case(funct3)
            3'd0: begin
                if (r_offset == 2'd0) loadregvalue = {{24{loadvalue_word[7]}},loadvalue_word[7:0]};
                else if (r_offset == 2'd1) loadregvalue = {{24{loadvalue_word[15]}},loadvalue_word[15:8]};
                else if (r_offset == 2'd2) loadregvalue = {{24{loadvalue_word[23]}},loadvalue_word[23:16]};
                else loadregvalue = {{24{loadvalue_word[31]}},loadvalue_word[31:24]};
            end
            3'd1: begin
                if (r_offset == 2'd0) loadregvalue = {{16{loadvalue_word[15]}},loadvalue_word[15:0]};
                else if (r_offset == 2'd1) loadregvalue ={{16{loadvalue_word[23]}},loadvalue_word[23:8]};
                else loadregvalue = {{16{loadvalue_word[31]}},loadvalue_word[31:16]};
            end
            3'd4: begin
                if (r_offset == 2'd0) loadregvalue = {{24{1'b0}},loadvalue_word[7:0]};
                else if (r_offset == 2'd1) loadregvalue = {{24{1'b0}},loadvalue_word[15:8]};
                else if (r_offset == 2'd2) loadregvalue = {{24{1'b0}},loadvalue_word[23:16]};
                else loadregvalue = {{24{1'b0}},loadvalue_word[31:24]};
            end
            3'd5: begin
                if (r_offset == 2'd0) loadregvalue = {{16{1'b0}},loadvalue_word[15:0]};
                else if (r_offset == 2'd1) loadregvalue ={{16{1'b0}},loadvalue_word[23:8]};
                else loadregvalue = {{16{1'b0}},loadvalue_word[31:16]};
            end
            default: loadregvalue = loadvalue_word;
        endcase
    end
endfunction

assign write_address = (is_store == `ENABLE) ? alu_result : 32'd0;
assign read_address = (is_load == `ENABLE) ? alu_result : 32'd0;
assign w_offset = write_address[1:0];
assign r_offset = read_addressMA[1:0];
assign storevalue_word = stword(is_store, funct3RR, w_offset, write_data);
assign load_reg_value = loadregvalue(loadvalue_word, funct3MA, r_offset);
assign write_en_bm = writebm(is_store, funct3RR, w_offset);

endmodule
