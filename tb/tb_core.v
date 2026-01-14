`timescale 1ns / 1ps

module tb_core;

    reg clk, rst_n;
    wire [31:0] result;

    riscv_core uut (
        .clk(clk),
        .rst_n(rst_n),
        .result_o(result)
    );

    // Clock Generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize
        clk = 0; rst_n = 0;
        
        // 2. Reset the Processor
        #10 rst_n = 1;
        
        $display("------------------------------------------------");
        $display(" RISC-V CORE SIMULATION START ");
        $display("------------------------------------------------");

        // 3. Monitor the execution
        // We wait for a few clock cycles to let the instructions execute
        
        // Cycle 1: ADDI x1, x0, 5  (Result should be 5)
        @(posedge clk); #1; 
        $display("Time: %0t | Result: %d (Expected: 5 from ADDI x1,0,5)", $time, result);

        // Cycle 2: ADDI x2, x0, 10 (Result should be 10)
        @(posedge clk); #1;
        $display("Time: %0t | Result: %d (Expected: 10 from ADDI x2,0,10)", $time, result);

        // Cycle 3: ADD x3, x1, x2 (Result should be 15)
        @(posedge clk); #1;
        $display("Time: %0t | Result: %d (Expected: 15 from ADD x3,x1,x2)", $time, result);
        
        // Cycle 4: NOP (Result stays 15 or 0 depending on implementation)
        @(posedge clk); #1;
        $display("Time: %0t | Result: %d", $time, result);

        $display("------------------------------------------------");
        $finish;
    end

endmodule