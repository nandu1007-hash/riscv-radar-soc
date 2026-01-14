// ---------------------------------------------------------------------
// Module: Control Unit
// Description: Decodes the Opcode/Funct3/Funct7 to generate control signals.
// ---------------------------------------------------------------------

module control_unit (
    input  wire [6:0]  opcode_i,
    input  wire [2:0]  funct3_i,
    input  wire [6:0]  funct7_i,

    // Control Signals (The Commands)
    output reg         reg_write_o, // 1 = Write to Register File
    output reg         mem_write_o, // 1 = Write to Data Memory
    output reg         mem_to_reg_o,// 1 = Load Data from Memory, 0 = ALU Result
    output reg         alu_src_o,   // 0 = Reg x2, 1 = Immediate
    output reg  [3:0]  alu_ctrl_o,  // 4-bit ALU Operation Code
    output reg         branch_o     // 1 = This is a Branch instruction
);

    // ALU Operation Codes (Must match your alu.v)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b1000;
    localparam ALU_AND  = 4'b0111;
    localparam ALU_OR   = 4'b0110;
    // ... add others as needed

    always @(*) begin
        // Default Defaults (Safe State: Do nothing)
        reg_write_o  = 0;
        mem_write_o  = 0;
        mem_to_reg_o = 0;
        alu_src_o    = 0;
        alu_ctrl_o   = ALU_ADD;
        branch_o     = 0;

        case (opcode_i)
            // -----------------------------------------
            // R-TYPE (Register-Register Math: add, sub, and, or)
            // -----------------------------------------
            7'b0110011: begin 
                reg_write_o = 1; // We save the result
                alu_src_o   = 0; // Use Register x2 (not Immediate)
                
                // Decode specific math operation using Funct3/Funct7
                case ({funct7_i, funct3_i})
                    10'b0000000_000: alu_ctrl_o = ALU_ADD; // ADD
                    10'b0100000_000: alu_ctrl_o = ALU_SUB; // SUB
                    10'b0000000_111: alu_ctrl_o = ALU_AND; // AND
                    10'b0000000_110: alu_ctrl_o = ALU_OR;  // OR
                    default:         alu_ctrl_o = ALU_ADD;
                endcase
            end

            // -----------------------------------------
            // I-TYPE (Immediate Math: addi, andi...)
            // -----------------------------------------
            7'b0010011: begin
                reg_write_o = 1;
                alu_src_o   = 1; // Use Immediate Value!
                
                case (funct3_i)
                    3'b000: alu_ctrl_o = ALU_ADD; // ADDI
                    3'b111: alu_ctrl_o = ALU_AND; // ANDI
                    3'b110: alu_ctrl_o = ALU_OR;  // ORI
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            // -----------------------------------------
            // LOAD (lw)
            // -----------------------------------------
            7'b0000011: begin
                reg_write_o  = 1; // We write the loaded data to reg
                mem_to_reg_o = 1; // Source is Memory, not ALU
                alu_src_o    = 1; // Address is Reg + Imm
                alu_ctrl_o   = ALU_ADD; // Address calculation is ADD
            end

            // -----------------------------------------
            // STORE (sw)
            // -----------------------------------------
            7'b0100011: begin
                reg_write_o = 0; // Don't touch registers!
                mem_write_o = 1; // Write to Memory
                alu_src_o   = 1; // Address is Reg + Imm
                alu_ctrl_o  = ALU_ADD;
            end

            // -----------------------------------------
            // BRANCH (beq)
            // -----------------------------------------
            7'b1100011: begin
                branch_o    = 1; // Tell logic we might jump
                reg_write_o = 0;
                alu_src_o   = 0; // Compare two registers
                alu_ctrl_o  = ALU_SUB; // Compare by subtracting
            end
        endcase
    end

endmodule