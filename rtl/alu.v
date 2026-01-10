// ---------------------------------------------------------------------
// Module: ALU (Arithmetic Logic Unit)
// Project: RISC-V Radar SoC
// Description: 32-bit ALU supporting RV32I operations (ADD, SUB, LOGIC, SHIFTS)
// ---------------------------------------------------------------------

module alu (
    input  wire [31:0]  a_i,          // Operand A
    input  wire [31:0]  b_i,          // Operand B
    input  wire [3:0]   alu_ctrl_i,   // Operation Selection Control
    output reg  [31:0]  result_o,     // ALU Result
    output wire         zero_o        // Zero Flag (High if result is 0)
);

    // encoding: defined based on RISC-V funct3/funct7 conventions usually
    // But for this internal module, we define our own simple mapping:
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b1000;
    localparam ALU_SLL  = 4'b0001; // Shift Left Logical
    localparam ALU_SLT  = 4'b0010; // Set Less Than (Signed)
    localparam ALU_SLTU = 4'b0011; // Set Less Than (Unsigned)
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SRL  = 4'b0101; // Shift Right Logical
    localparam ALU_OR   = 4'b0110;
    localparam ALU_AND  = 4'b0111;
    localparam ALU_SRA  = 4'b1101; // Shift Right Arithmetic

    always @(*) begin
        case (alu_ctrl_i)
            ALU_ADD:  result_o = a_i + b_i;
            ALU_SUB:  result_o = a_i - b_i;
            ALU_AND:  result_o = a_i & b_i;
            ALU_OR:   result_o = a_i | b_i;
            ALU_XOR:  result_o = a_i ^ b_i;
            ALU_SLL:  result_o = a_i << b_i[4:0];  // RISC-V only uses lower 5 bits for shift
            ALU_SRL:  result_o = a_i >> b_i[4:0];
            ALU_SRA:  result_o = $signed(a_i) >>> b_i[4:0]; // Arithmetic shift (preserves sign)
            ALU_SLT:  result_o = ($signed(a_i) < $signed(b_i)) ? 32'd1 : 32'd0;
            ALU_SLTU: result_o = (a_i < b_i) ? 32'd1 : 32'd0;
            default:  result_o = 32'd0;
        endcase
    end

    // Zero Flag is needed for Branch Instructions (BEQ)
    assign zero_o = (result_o == 32'd0);

endmodule