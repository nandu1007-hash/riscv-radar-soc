// ---------------------------------------------------------------------
// Module: Decoder
// Description: Unpacks the 32-bit instruction into control signals.
//              Also handles "Sign Extension" for Immediate values.
// ---------------------------------------------------------------------

module decoder (
    input  wire [31:0] instr_i,     // The full instruction
    
    // Unpacked Control Signals
    output wire [6:0]  opcode_o,
    output wire [4:0]  rd_o,
    output wire [2:0]  funct3_o,
    output wire [6:0]  funct7_o,
    output wire [4:0]  rs1_o,
    output wire [4:0]  rs2_o,
    
    // Immediate Value (Extended to 32 bits)
    output reg  [31:0] imm_o
);

    // 1. Simple Slicing (Just wires)
    assign opcode_o = instr_i[6:0];
    assign rd_o     = instr_i[11:7];
    assign funct3_o = instr_i[14:12];
    assign rs1_o    = instr_i[19:15];
    assign rs2_o    = instr_i[24:20];
    assign funct7_o = instr_i[31:25];

    // 2. Immediate Generation (The Tricky Part)
    // RISC-V scrambles the "Immediate" (constant) bits differently 
    // depending on the instruction type.
    always @(*) begin
        case (opcode_o)
            // Type I (Arithmetic Immediate, Load) -> imm[11:0] is at instr[31:20]
            7'b0010011, 7'b0000011, 7'b1100111: begin 
                // Sign Extend: Copy bit 31 to all upper bits
                imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
            end
            
            // Type S (Store) -> imm is split into two parts
            7'b0100011: begin
                imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end

            // Type B (Branch) -> Very scrambled!
            7'b1100011: begin
                imm_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            end
            
            // Default (Use I-Type or 0)
            default: imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
        endcase
    end

endmodule