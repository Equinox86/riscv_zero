
// RV32I Opcode Definitions (RV)
`define `LOAD     7'b00000_11      // Load instructions
`define `OPIMM    7'b00100_11      // Arithmetic Immediate instructions
`define `AUIPC    7'b00101_11      // AUIPC instruction
`define `STORE    7'b01000_11      // Store instructions
`define `OP       7'b01100_11      // Arithmetic instructions
`define `LUI      7'b01101_11      // LUI instruction
`define `BEQ      7'b11000_11      // Branch instructions
`define `JALR     7'b11001_11      // JALR instruction
`define `JAL      7'b11011_11      // JAL instruction
`define `SYSTEM   7'b11100_11      // System instructions
 
`define ALL0 32'h0000_0000 // All zero constant
`define ALL1 32'hFFFF_FFFF // All one constant
`define ALLX 32'hXXXX_XXXX // All don't care constant
`define ALLZ 32'hZZZZ_ZZZZ // All high impedance constant

module riscv_zero(
    input clk,                  // Clock signal
    input reset,                // Reset signal  

    // Fetch stage
    input  [31:0] pc_in,       // Program Counter Input
    input  [31:0] inst_data,    // Instruction Data
    output [31:0] inst_addr,    // Instruction Address
    input  [31:0] data_in,      // Data Bus Input 

    output [31:0] data_out,     // Data Bus Output
    output [31:0] address,      // Address Bus Output
);


// Unprivileged integer resgister states (RISC-V 2.1)
reg [31:0] x0; // Zero register
reg [31:0] REG [0:30] regfile; // Register file x0 to x30
reg [31:0]; // Program counter

reg [31:0] rs1; // Source register 1
reg [31:0] rs2; // Source register 2
reg [31:0] rd;  // Destination register
reg [31:0] imm; // Immediate value
reg [31:0] pc_next; // Program counter

// Instruction fetch
assign inst_addr = pc_in; // Set instruction address to current PC
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_next <= 32'h0000_0000; // Reset PC to zero
    end else begin
        pc_next <= pc_in + 4; // Increment PC by 4 for next instruction
    end
end
endmodule