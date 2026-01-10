`timescale 1ns / 1ps

module tb_alu;

    // Signals to connect to ALU
    reg  [31:0] a, b;
    reg  [3:0]  ctrl;
    wire [31:0] res;
    wire        zero;

    // Instantiate the ALU
    alu uut (
        .a_i(a),
        .b_i(b),
        .alu_ctrl_i(ctrl),
        .result_o(res),
        .zero_o(zero)
    );

    initial begin
        $display("--------------------------------");
        $display("    STARTING ALU SIMULATION     ");
        $display("--------------------------------");

        // 1. Test ADD (10 + 5)
        a = 10; b = 5; ctrl = 4'b0000; 
        #10; // Wait 10ns
        if (res === 15) $display("[PASS] ADD: 10 + 5 = %d", res);
        else            $display("[FAIL] ADD: 10 + 5 = %d (Expected 15)", res);

        // 2. Test SUB (20 - 5)
        a = 20; b = 5; ctrl = 4'b1000;
        #10;
        if (res === 15) $display("[PASS] SUB: 20 - 5 = %d", res);
        else            $display("[FAIL] SUB: 20 - 5 = %d (Expected 15)", res);

        // 3. Test AND (0xF0 & 0x0F) -> Should be 0
        a = 32'h000000F0; b = 32'h0000000F; ctrl = 4'b0111;
        #10;
        if (res === 0 && zero === 1) $display("[PASS] AND: Result is 0, Zero Flag is 1");
        else                         $display("[FAIL] AND Result: %h", res);

        $display("--------------------------------");
        $finish;
    end

endmodule