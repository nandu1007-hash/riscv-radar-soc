`timescale 1ns/1ps
// ---------------------------------------------------------------------
// Module: Register File
// Description: 32x32-bit register bank.
//   - 2 Read Ports (rs1, rs2) -> Asynchronous (instant output)
//   - 1 Write Port (rd)       -> Synchronous (updates on clock edge)
//   - x0 is HARDWIRED to 0.
// ---------------------------------------------------------------------

module reg_file (
    input  wire        clk,         // System Clock
    input  wire        rst_n,       // Active-low Reset (clears all registers)
    
    // Read Ports (Inputs)
    input  wire [4:0]  raddr1_i,    // Address of Source Register 1 (rs1)
    input  wire [4:0]  raddr2_i,    // Address of Source Register 2 (rs2)
    
    // Write Port (Inputs)
    input  wire [4:0]  waddr_i,     // Address of Destination Register (rd)
    input  wire [31:0] wdata_i,     // Data to write into rd
    input  wire        we_i,        // Write Enable (1 = Write, 0 = Read only)
    
    // Outputs
    output wire [31:0] rdata1_o,    // Data from rs1
    output wire [31:0] rdata2_o     // Data from rs2
);

    // 1. Create the Memory Array (32 registers, each 32-bits wide)
    reg [31:0] regs [0:31];
    integer i; // Variable for loop

    // 2. Write Logic (Synchronous)
    // We verify the design works by clearing registers on Reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // On Reset: Loop through all 32 and set to 0
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else if (we_i && (waddr_i != 5'b0)) begin
            // WRITE Condition:
            // 1. Write Enable (we_i) is HIGH.
            // 2. Address is NOT x0 (waddr_i != 0). We protect x0.
            regs[waddr_i] <= wdata_i;
        end
    end

    // 3. Read Logic (Asynchronous / Combinational)
    // If address is 0, return 0. Otherwise return stored value.
    assign rdata1_o = (raddr1_i == 5'b0) ? 32'b0 : regs[raddr1_i];
    assign rdata2_o = (raddr2_i == 5'b0) ? 32'b0 : regs[raddr2_i];

endmodule