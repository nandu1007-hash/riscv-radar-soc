`timescale 1ns / 1ps

module tb_reg_file;

    // Signals
    reg clk, rst_n, we;
    reg [4:0] raddr1, raddr2, waddr;
    reg [31:0] wdata;
    wire [31:0] rdata1, rdata2;

    // Instantiate Unit Under Test (UUT)
    reg_file uut (
        .clk(clk), .rst_n(rst_n),
        .raddr1_i(raddr1), .raddr2_i(raddr2),
        .waddr_i(waddr), .wdata_i(wdata), .we_i(we),
        .rdata1_o(rdata1), .rdata2_o(rdata2)
    );

    // Clock Generation (50 MHz)
    always #10 clk = ~clk; 

    initial begin
        // Initialize
        clk = 0; rst_n = 0; we = 0;
        waddr = 0; wdata = 0; raddr1 = 0; raddr2 = 0;

        // Reset the chip
        #20 rst_n = 1; 

        // Test 1: Write 0xDEADBEEF to Register x1
        $display("Test 1: Writing to x1...");
        @(posedge clk);
        we = 1; waddr = 5'd1; wdata = 32'hDEADBEEF;
        @(posedge clk);
        we = 0; // Turn off write

        // Read it back
        raddr1 = 5'd1;
        #1; // Wait a tiny bit for async read
        if (rdata1 === 32'hDEADBEEF) $display("[PASS] x1 contains DEADBEEF");
        else $display("[FAIL] x1 = %h", rdata1);

        // Test 2: Try to Write to x0 (Should fail)
        $display("Test 2: Writing to x0 (Should stay 0)...");
        @(posedge clk);
        we = 1; waddr = 5'd0; wdata = 32'hFFFFFFFF;
        @(posedge clk);
        we = 0;

        raddr1 = 5'd0;
        #1;
        if (rdata1 === 32'h0) $display("[PASS] x0 is still 0");
        else $display("[FAIL] x0 was overwritten! Value: %h", rdata1);

        $finish;
    end
endmodule