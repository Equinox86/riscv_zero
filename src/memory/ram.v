module ram (
    input clk,                  // Clock signal
    input reset,                // Reset signal
    input reg write_enable,         // Write enable signal
    input reg [31:0] address,   // Address Bus Output
    input reg [31:0] data_in,      // Data Bus Input 
    output reg [31:0] data_out // Data Bus Output
);

integer i;

reg [8:0] memory [0:1023]; // Memory array of 1kB

always @(posedge clk or posedge reset) begin
    if (write_enable) begin
        for (i = 0; i < 4; i = i + 1) begin
            memory[address + i] <= data_in[(i*8) +: 8]; // Write each byte
        end
    end else begin
        for(i = 0; i < 4; i = i + 1) begin
            data_out[(i*8) +: 8] <= memory[address + i]; // Read each byte
        end
    end
end
endmodule

