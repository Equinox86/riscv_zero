module riscv_zero_decode (
    input clk,
    input reset,
    input [31:0] inst_data,
    input [31:0] pc_in,

    // Register file writeback control
    input reg_wenable;
    input reg_waddr[4:0];
    input reg_wdata[63:0];

    // Decode output registers to Execute
    output reg [31:0] immediate;
    output reg [4:0]  reg_dest;
    output reg [63:0] reg1_out,
    output reg [63:0] reg2_out,
    output reg [31:0] pc_out,

    // Decode control registers
    output reg writeback_enable;
    output reg [1:0] writeback_source;
    output reg mem_wenable;
    output reg jump;
    output reg branch;
    output reg ALU_A_mux;
    output reg ALU_B_mux;
)

//
// Control wire assignments
//
assign wire [6:0] funct7 = inst_data[31:25]; // 7-bit function code
assign wire [2:0] funct3 = inst_data[14:12]; // 3-bit function code
assign wire [6:0] op = inst_data[6:0];       // Operation Code
assign wire [4:0] rs1 = inst_data[19:15];    // Register file source1 address
assign wire [4:0] rs2 = inst_data[24:20];    // Register file source2 address
assign wire [4:0] rd = inst_data[11:7];      // Register file destination address

//hart register file: XLEN = 64
reg [63:0] register_file [0:31];

always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode <= 7'b0000000;
        reg_dest <= 5'b00000;
        rs1 <= 5'b00000;
        rs2 <= 5'b00000;
        imm <= 32'h0;
        register_file[0] <= 32'h0;
    end else begin
        opcode <= inst_data[6:0];

        // Reset control signals
        writeback_enable <= 1'b0;   // 0 - no write to rd; 1 - write back to rd.
        writeback_source <= 2'b00;  // 00 - ALU, 01 - Memory, 10 - Immediate, 11 - PC+4
        memory_access <= 2'b00;     // 00 - no memory access, 01 - memory read access, 10 - memory write access
        jump <= 1'b0;               // 0 - do not jump and link, 1 - jump and link
        branch <= 1'b0;             // 0 - no branch, 1 - branching
        ALU_A_mux <= 1'b0;          // 0 - use reg1_out, 1 - use pc
        ALU_B_mux <= 1'b0;          // 0 - use reg2_out, 1 - use immediate value

        // Immediate Values
        case (opcode)
            // RV32I OPCODES
            7'b0010011: immediate <= $signed(inst_data[31:20]);                                                      // I-Type Immediate
            7'b0100011: immediate <= $signed({inst_data[31:25], inst_data[11:7]});                                   // S-Type Immediate
            7'b1100011: immediate <= $signed({inst_data[7], inst_data[30:25], inst_data[11:8]});                     // B-Type Immediate
            7'b0110111: immediate <= {inst_data[31:20], inst_data[19:12], {12{0}}};                                  // U-Type Immediate
            7'b1101111: immediate <= $signed({inst_data[19:12], inst_data[20], inst_data[30:21], 1'b0});             // J-Type Immediate
            // RV64I OPCODES=inst_data[19:12]
            7'b0011011: immediate <= {{20{inst_data[31]}}, inst_data[31:20]}; // I-Type Immediate
            default: immediate <= 32'h0000_0000;
        endcase

        // Control Signals
        case(opcode):
            7'b0000011: // Load Immediate
                memory_access <= 2'b01
                writeback_enable <= 1'b1;
                writeback_source <= 2'b01;
                ALU_B_mux <= 1'b1;
            7'b0010011: // ALU Immediate Ops
                writeback_enable <= 1'b1;
                ALU_B_control <= 1'b1;
            7'b0010111: // PC + Upper Immediate (AUIPC)
                writeback_enable <= 1'b1;
                ALU_A_mux <= 1'b1
                ALU_B_mux <= 1'b1
            7'b0100011: // Store
                memory_access <= 2'b10;
                writeback_source <= 2'b01
                ALU_B_mux <= 1'b1;
            7'b0110011: // ALU Register Ops
                writeback_enable <= 1'b1;
            7'b0110111: // Load upper immeidate (LUI)
                writeback_source <= 2'b10;
            7'1100011: // Branch
                branch <= 1'b1
            7'1100011: // Jump and link register (JALR)
                jump <= 1'b1
                writeback_source <= 2'b11;
                writeback_enable <= 1'b1;
            7'1100011: // Jump and link(JAL)
                jump <= 1'b1
                writeback_source <= 2'b11;
                writeback_enable <= 1'b1;

        endcase
        // Register Access
        reg_dest <= rd;
        reg1_out <= register_file[rs1];
        reg2_out <= register_file[rs2];
        if (reg_wenable) begin
            register_file[reg_waddr] <= reg_wdata;
        end
        register_file[31] <= pc_in;
        register_file[0] <= 32'h0;
    end
end

endmodule