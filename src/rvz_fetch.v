// rvz_fetch.v
// RISC-V Zero Fetch Module
// This module handles instruction fetching in the RISC-V Zero architecture
// This is a simplified version of the fetch stage which assumes a single-cycle fetch
// without cache or ram control logic.

module riscv_zero_fetch(
    input clk,                  // Clock signal
    input reset,                // Reset signal
    input branch_taken,        // Branch taken signal
    input  [31:0] pc_in,       // Program Counter Input
    input  [31:0] inst_data,    // Instruction Data from memory

    // Output to the next stage
    output reg [31:0] pc_out, // output the PC for debug purposes
    output reg [31:0] d_inst_data   // Instruction Data to Decode stage
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 32'h0000_0000; // Reset PC to zero
        d_inst_data <= 32'h0000_0000; // Reset instruction data
    end else begin
        d_inst_data <= inst_data; // Fetch instruction data
        pc_out <= branch_taken ? pc_in : pc_out + 4;
    end
end

endmodule