`timescale 1ns / 1ps

module tb_pc;

    reg clk, rst_n;
    reg [31:0] pc_next;
    wire [31:0] pc_out;

    pc uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next_i(pc_next),
        .pc_o(pc_out)
    );

    // Clock Generator
    always #10 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; pc_next = 0;
        
        // 1. Check Reset
        #25 rst_n = 1; // Release reset
        if (pc_out === 0) $display("[PASS] Reset works. PC is 0.");
        else $display("[FAIL] PC is %h after reset", pc_out);

        // 2. Simulate standard execution (PC = PC + 4)
        @(posedge clk);
        pc_next = 32'd4; // Tell PC to go to address 4 next
        
        @(posedge clk);
        #1; // Wait for output
        if (pc_out === 4) $display("[PASS] PC incremented to 4.");
        else $display("[FAIL] Expected 4, got %d", pc_out);

        // 3. Simulate a JUMP (e.g. Function Call)
        pc_next = 32'h0000_1000; // Jump to address 4096 (0x1000)
        
        @(posedge clk);
        #1;
        if (pc_out === 32'h1000) $display("[PASS] Jump works. PC is 0x1000.");
        
        $finish;
    end

endmodule