module alu (
    input [63:0] a,
    input [63:0] b,
    input [3:0] operation,
    output [63:0] result
);

always @* begin
    case (operation)
        4'h0: begin
            result = a + b;
        end
        4'h1: begin
            result = a - b;
        end
        4'h2: begin
            result = a << b;
        end
        4'h3: begin
            result = a < b;
        end
        4'h4: begin
            result = a ^ b;
        end
        4'h5: begin
            result = a >> b;
        end
        4'h6: begin
            result = a >>> b;
        end
        4'h7: begin
            result = a | b;
        end
        4'h8: begin
            result = a & b;
        end
        4'h9: begin
            result = a == b;
        end
    endcase
end

endmodule