// ---------------------------------------------------------------------
// Module: Program Counter (PC)
// Description: Holds the address of the current instruction.
// ---------------------------------------------------------------------

module pc (
    input  wire        clk,        // System Clock
    input  wire        rst_n,      // Active-Low Reset
    input  wire [31:0] pc_next_i,  // The address of the NEXT instruction
    output reg  [31:0] pc_o        // The address of the CURRENT instruction
);

    // On every rising edge of the clock, update the PC.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // On Reset, start at address 0.
            // (In real chips, this might be 0x8000_0000, but 0 is fine for us)
            pc_o <= 32'b0;
        end else begin
            // Otherwise, jump to wherever the logic tells us to go.
            pc_o <= pc_next_i;
        end
    end

endmodule