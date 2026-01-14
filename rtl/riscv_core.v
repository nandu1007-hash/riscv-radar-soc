// ---------------------------------------------------------------------
// Module: RISC-V Core (Top Level)
// Description: Connects PC, ALU, RegFile, Decoder, Control Unit, and RAM.
// ---------------------------------------------------------------------

module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] result_o // Debug output to see what the ALU is doing
);

    // =================================================================
    // 1. Internal Wires (The "Nerves")
    // =================================================================
    
    // PC Signals
    wire [31:0] pc_current, pc_next, pc_plus_4, pc_branch;
    
    // Instruction Memory Signals
    wire [31:0] instr;
    
    // Decoder Signals
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;
    
    // Control Unit Signals
    wire reg_write, mem_write, mem_to_reg, alu_src, branch;
    wire [3:0] alu_ctrl;
    
    // Register File Signals
    wire [31:0] rdata1, rdata2;
    wire [31:0] wdata; // Data to be written back to RegFile

    // ALU Signals
    wire [31:0] alu_src_b; // The second input to ALU (Reg or Imm?)
    wire [31:0] alu_result;
    wire        zero_flag;

    // =================================================================
    // 2. Module Instantiations (The "Organs")
    // =================================================================

    // --- FETCH STAGE ---
    
    // Program Counter
    pc pc_inst (
        .clk(clk), .rst_n(rst_n),
        .pc_next_i(pc_next),
        .pc_o(pc_current)
    );

    // Instruction Memory
    instr_mem imem_inst (
        .addr_i(pc_current),
        .instr_o(instr)
    );
    
    // Next PC Logic (Adder + Mux)
    assign pc_plus_4 = pc_current + 4;
    assign pc_branch = pc_current + imm; // Branch Target
    
    // PC Mux: If (Branch Instruction AND Zero Flag is 1), then Jump!
    assign pc_next = (branch && zero_flag) ? pc_branch : pc_plus_4;


    // --- DECODE STAGE ---
    
    // Decoder
    decoder dec_inst (
        .instr_i(instr),
        .opcode_o(opcode), .rd_o(rd), 
        .rs1_o(rs1), .rs2_o(rs2),
        .funct3_o(funct3), .funct7_o(funct7),
        .imm_o(imm)
    );

    // Control Unit
    control_unit cu_inst (
        .opcode_i(opcode), .funct3_i(funct3), .funct7_i(funct7),
        .reg_write_o(reg_write), .mem_write_o(mem_write),
        .mem_to_reg_o(mem_to_reg), .alu_src_o(alu_src),
        .alu_ctrl_o(alu_ctrl), .branch_o(branch)
    );

    // Register File
    reg_file rf_inst (
        .clk(clk), .rst_n(rst_n),
        .raddr1_i(rs1), .raddr2_i(rs2),
        .waddr_i(rd),
        .wdata_i(wdata), // This comes from Writeback Mux
        .we_i(reg_write),
        .rdata1_o(rdata1), .rdata2_o(rdata2)
    );


    // --- EXECUTE STAGE ---

    // ALU Mux: Select between Register Data (rdata2) or Immediate (imm)
    assign alu_src_b = (alu_src) ? imm : rdata2;

    // ALU
    alu alu_inst (
        .a_i(rdata1),
        .b_i(alu_src_b),
        .alu_ctrl_i(alu_ctrl),
        .result_o(alu_result),
        .zero_o(zero_flag)
    );
    
    // --- MEMORY / WRITEBACK STAGE ---
    
    // Note: We are skipping Data Memory (RAM) for now to keep it simple.
    // We just loop the ALU result back to the Register File.
    // Later we will add: assign wdata = (mem_to_reg) ? mem_data : alu_result;
    
    assign wdata = alu_result; 

    // Output for Testbench
    assign result_o = alu_result;

endmodule