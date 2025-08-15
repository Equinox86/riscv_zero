module alu (
    input [31:0] a,           // First operand
    input [31:0] b,           // Second operand
    input [2:0] operation,    // Operation selector
    output reg [31:0] result,  // Result of the operation
    output reg carry           // Zero flag
);

always @(*) begin
    case (operation)
        3'b000: begin // Addition
            {carry, result} = a + b;
        end
        3'b001: begin // Subtraction
            {carry, result} = a - b;
        end
        3'b010: begin // Bitwise AND
            result = a & b;
            carry = 0; // No carry for bitwise operations
        end
        3'b011: begin // Bitwise OR
            result = a | b;
            carry = 0; // No carry for bitwise operations
        end
        3'b100: begin // Bitwise XOR
            result = a ^ b;
            carry = 0; // No carry for bitwise operations
        end
        default: begin // Default case (no operation)
            result = 32'h00000000;
            carry = 0;
        end
    endcase
end
endmodule