// ---------------------------------------------------------------------
// Module: Instruction Memory
// Description: Read-Only Memory (ROM) that holds the program code.
//              Uses $readmemh to load a hex file during simulation.
// ---------------------------------------------------------------------

module instr_mem (
    input  wire [31:0] addr_i,  // Address from PC
    output wire [31:0] instr_o  // The Instruction machine code
);

    // Create a memory array: 1024 lines, each 32-bits wide.
    // (Enough for small C programs)
    reg [31:0] mem [0:1023];

    // The Logic: Read the data.
    // Note: We use [31:2] to divide the address by 4.
    assign instr_o = mem[addr_i[31:2]];

    // SIMULATION ONLY: Load the "program.hex" file into this memory.
    // This tells the simulator: "Fill this memory with these numbers."
    initial begin
        $readmemh("program.hex", mem);
    end

endmodule