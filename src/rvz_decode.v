module riscv_zero_decode (
    input clk,
    input reset,
    input [31:0] inst_data,
    input [31:0] pc_in,

    // Register file writeback control
    input reg_wenable,
    input [4:0] reg_waddr,
    input [63:0] reg_wdata,

    // Decode output registers to Execute
    output reg [6:0] opcode,
    output reg [31:0] immediate,
    output reg [4:0]  reg_dest,
    output reg [63:0] reg1_out,
    output reg [63:0] reg2_out,
    output reg [31:0] pc_out,
    output reg [6:0] funct7_out, 
    output reg [2:0] funct3_out, 

    // Decode control registers
    output reg writeback_enable,
    output reg memory_access,
    output reg [1:0] writeback_source,
    output reg mem_wenable,
    output reg jump,
    output reg branch,
    output reg ALU_A_mux,
    output reg ALU_B_mux
);

//
// Control wire assigments
//

wire [6:0] funct7 = inst_data[31:25]; // 7-bit function code
wire [2:0] funct3 = inst_data[14:12]; // 3-bit function code
wire [6:0] op = inst_data[6:0];       // Operation Code
wire [4:0] rs1 = inst_data[19:15];    // Register file source1 address
wire [4:0] rs2 = inst_data[24:20];    // Register file source2 address
wire [4:0] rd = inst_data[11:7];      // Register file destination address

//hart register file: XLEN = 64
reg [63:0] register_file [0:31];

always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode <= 7'b0000000;
        reg_dest <= 5'b00000;
        reg1_out <= 5'b00000;
        reg2_out <= 5'b00000;
        immediate <= 32'h0;
        register_file[0] <= 32'h0;
    end else begin
        // Reset control signals
        writeback_enable <= 1'b0;   // 0 - no write to rd; 1 - write back to rd.
        writeback_source <= 2'b00;  // 00 - ALU, 01 - Memory, 10 - Immediate, 11 - PC+4
        memory_access <= 2'b00;     // 00 - no memory access, 01 - memory read access, 10 - memory write access
        jump <= 1'b0;               // 0 - do not jump and link, 1 - jump and link
        branch <= 1'b0;             // 0 - no branch, 1 - branching
        ALU_A_mux <= 1'b0;          // 0 - use reg1_out, 1 - use pc
        ALU_B_mux <= 1'b0;          // 0 - use reg2_out, 1 - use immediate value

        // Immediate Values
        case (op)
            7'b0010011,7'b0011011,7'b0000011: immediate <= $signed(inst_data[31:20]);                        // I-Type Immediate
            7'b0100011: immediate <= $signed({inst_data[31:25], inst_data[11:7]});                            // S-Type Immediate
            7'b1100011: immediate <= $signed({inst_data[7], inst_data[30:25], inst_data[11:8]});              // B-Type Immediate
            7'b0110111: immediate <= {inst_data[31:20], inst_data[19:12], {12{1'b0}}};                        // U-Type Immediate
            7'b1101111: immediate <= $signed({inst_data[19:12], inst_data[20], inst_data[30:21], 1'b0});      // J-Type Immediate
            default: immediate <= 32'h0000_0001;
        endcase

        // Control Signals
        case(op)
            7'b0000011: begin // Load Immediate
                memory_access <= 2'b01;
                writeback_enable <= 1'b1;
                writeback_source <= 2'b01;
                ALU_B_mux <= 1'b1;
            end
            7'b0010011,7'b0011011: begin // ALU Immediate Ops
                writeback_enable <= 1'b1;
                ALU_B_mux <= 1'b1;
            end
            7'b0010111: begin // PC + Upper Immediate (AUIPC)
                writeback_enable <= 1'b1;
                ALU_A_mux <= 1'b1;
                ALU_B_mux <= 1'b1;
            end
            7'b0100011: begin // Store
                memory_access <= 2'b10;
                writeback_source <= 2'b01;
                ALU_B_mux <= 1'b1;
            end
            7'b0110011,7'b0111011: begin// ALU Register Ops
                writeback_enable <= 1'b1;
            end
            7'b0110111: begin // Load upper immeidate (LUI)
                writeback_source <= 2'b10;
            end
            7'b1100011: begin // Branch
                branch <= 1'b1;
            end
            7'b1100011: begin // Jump and link register (JALR)
                jump <= 1'b1;
                writeback_source <= 2'b11;
                writeback_enable <= 1'b1;
            end
            7'b1100011: begin // Jump and link(JAL)
                jump <= 1'b1;
                writeback_source <= 2'b11;
                writeback_enable <= 1'b1;
            end
        endcase
        opcode <= inst_data[6:0];
        funct3_out <= funct3 ;
        funct7_out <= funct7;

        // Register Access
        reg_dest <= rd;
        reg1_out <= register_file[rs1];
        reg2_out <= register_file[rs2];
        if (reg_wenable) begin
            register_file[reg_waddr] <= reg_wdata;
        end
        register_file[31] <= pc_in;
    end
end

endmodule