`timescale 1ns / 1ps

module tb_decoder;

    reg [31:0] instr;
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [31:0] imm;

    decoder uut (
        .instr_i(instr),
        .opcode_o(opcode),
        .rd_o(rd),
        .rs1_o(rs1),
        .rs2_o(rs2),
        .imm_o(imm)
    );

    initial begin
        // Test: ADDI x1, x0, 5 -> Hex: 00500093
        instr = 32'h00500093;
        #10;
        
        $display("Instruction: %h", instr);
        $display("Opcode: %b (Expected 0010011)", opcode);
        $display("Dest Reg (rd): %d (Expected 1)", rd);
        $display("Immediate: %d (Expected 5)", imm);

        if (opcode === 7'b0010011 && rd === 1 && imm === 5)
            $display("[PASS] Decoder correctly unpacked ADDI");
        else
            $display("[FAIL] Decoder outputs incorrect");
            
        $finish;
    end

endmodule