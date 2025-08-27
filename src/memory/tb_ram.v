`timescale 1ps/1ps

module tb_ram;
    reg clk;
    reg reset;
    reg write_enable;
    reg [63:0] address;
    reg [63:0] data_in;
    wire [63:0] data_out;

    // Instantiate the RAM module
    ram uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("tb_ram.vcd");
        $dumpvars(0, tb_ram);

        // Initialize signals
        clk = 0;
        reset = 1;
        write_enable = 0;
        address = 0;
        data_in = 0;

        // Release reset after some time
        #10 reset = 0;

        // Test writing to memory
        write_enable = 1;
        address = 4;
        data_in = 32'hA5A5A5A5; // Example data
        #10; // Wait for a clock cycle

        // Test reading from memory
        write_enable = 0;
        address = 4;
        #10; // Wait for a clock cycle

        // Check output
        if (data_out !== 32'hA5A5A5A5) begin
            $display("Test failed: Expected %h, got %h", 32'hA5A5A5A5, data_out);
        end else begin
            $display("Test passed: Read %h from address %d", data_out, address);
        end

        // Finish simulation
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk; // Toggle clock every 5 time units
endmodule