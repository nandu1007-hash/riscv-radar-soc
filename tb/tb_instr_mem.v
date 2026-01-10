`timescale 1ns / 1ps

module tb_instr_mem;

    reg  [31:0] addr;
    wire [31:0] instr;

    instr_mem uut (
        .addr_i(addr),
        .instr_o(instr)
    );

    initial begin
        // Test 1: Read Address 0 (Should be 00500093)
        addr = 32'd0;
        #10;
        if (instr === 32'h00500093) $display("[PASS] Address 0: %h", instr);
        else $display("[FAIL] Address 0: Expected 00500093, Got %h", instr);

        // Test 2: Read Address 4 (Should be 00A00113)
        addr = 32'd4;
        #10;
        if (instr === 32'h00A00113) $display("[PASS] Address 4: %h", instr);
        else $display("[FAIL] Address 4: Expected 00A00113, Got %h", instr);
        
        // Test 3: Read Address 8 (Should be 002081B3)
        addr = 32'd8;
        #10;
        if (instr === 32'h002081B3) $display("[PASS] Address 8: %h", instr);
        else $display("[FAIL] Address 8: Expected 002081B3, Got %h", instr);

        $finish;
    end

endmodule