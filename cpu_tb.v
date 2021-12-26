module cpu_tb;
    reg clk;
    reg cpu_resetn;
    wire uart_tx;
    parameter CYCLE = 100;

    always #(CYCLE/2) clk = ~clk;
    
    cpu cpu0(
        .clk(clk),
        .rst(cpu_resetn),
        .uart_tx(uart_tx)
    );

    initial begin
        #10 clk = 1'd0;
            cpu_resetn = 1'd0;
        #(CYCLE) cpu_resetn = 1'd1;
        #1000000 $finish;
    end
endmodule