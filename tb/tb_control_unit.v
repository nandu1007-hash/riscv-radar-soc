`timescale 1ns / 1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    wire reg_write, mem_write, alu_src;
    wire [3:0] alu_ctrl;

    control_unit uut (
        .opcode_i(opcode), .funct3_i(funct3), .funct7_i(funct7),
        .reg_write_o(reg_write), .mem_write_o(mem_write),
        .alu_src_o(alu_src), .alu_ctrl_o(alu_ctrl)
    );

    initial begin
        // Test 1: ADD (R-Type)
        opcode = 7'b0110011; funct3 = 0; funct7 = 0;
        #10;
        if (reg_write === 1 && alu_src === 0) $display("[PASS] ADD: RegWrite=1, ALUSrc=0");
        else $display("[FAIL] ADD Control Signals wrong");

        // Test 2: ADDI (I-Type)
        opcode = 7'b0010011; funct3 = 0; funct7 = 0;
        #10;
        if (reg_write === 1 && alu_src === 1) $display("[PASS] ADDI: RegWrite=1, ALUSrc=1 (Immediate)");
        else $display("[FAIL] ADDI Control Signals wrong");

        // Test 3: STORE (S-Type)
        opcode = 7'b0100011; funct3 = 0; funct7 = 0;
        #10;
        if (reg_write === 0 && mem_write === 1) $display("[PASS] SW: RegWrite=0, MemWrite=1");
        else $display("[FAIL] SW Control Signals wrong");

        $finish;
    end
endmodule