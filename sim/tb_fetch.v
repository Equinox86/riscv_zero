
`timescale 1ps/1ps

module tb_fetch;
    reg  clk;
    reg  reset;
    reg branch;
    reg  [31:0] pc_in;           // Program Counter Input
    wire [31:0] inst_data;      // Instruction Data from memory
    wire [31:0] d_inst_data;   // Instruction Data to Decode stage    wire [31:0] mem_pc;

    reg  mem_write_enable; // Write enable for loading ram
    reg  [31:0] mem_data_in;    // Data input to memory (not used in fetch)
    reg  [31:0] mem_write_data;    // Data input to memory (not used in fetch)
    wire [31:0] mem_pc;

    // Instantiate the RAM module for instruction memory
    ram inst_memory (
        .clk(clk),
        .reset(reset),
        .write_enable(mem_write_enable), // Read-only for fetch stage
        .address(mem_pc),     // Address for instruction fetch
        .data_in(mem_data_in), // No data input for read operation
        .data_out(inst_data) // Output instruction data
    );

    // Instantiate the tb_fetch module
    riscv_zero_fetch uut (
        .clk(clk),
        .reset(reset),
        .branch_taken(branch),
        .pc_in(pc_in),
        .pc_out(mem_pc) ,
        .inst_data(inst_data),
        .d_inst_data(d_inst_data)
    );

    initial begin
        $dumpfile("tb_fetch.vcd");
        $dumpvars(0, tb_fetch);

        // Initialize signals
        clk = 0;
        pc_in = 32'h0;
        branch = 0;
        reset = 1;
        #5 // 1/2 clock cycle for initialization

        //
        // Setup
        //

        // Preload instruction memory with some instructions
        reset = 0; mem_write_enable = 1;
        mem_data_in = 32'hABCD_1234;
        #10 // Write in to 0x0
        mem_data_in = 32'hABCD_5678;
        #10 // Write into 0x4
        mem_data_in = 32'h0808_0808;
        #50 // Write into 0x8
        mem_data_in = 32'hCAB1_DAB1;
        #10 // Write into 0x1C

        //
        // Testing
        //
        reset = 1; mem_write_enable = 0;
        #5 // Assert Reset - Disable Mem Write Enable
        reset = 0;
        #10 // Deassert Reset - Read instruction 0x0
        pc_in = 32'h1C; branch = 1;
        #10 // Assert branch; Read instruction 0x1
        branch = 0;
        #10 // Deassert Branch - Read instruction 0x1C
        pc_in = 32'h08; branch = 1;
        #10 // Assert Branch - Read instruction 0x20
        branch = 0;
        #10 // Deassert Branch - Read Instruction at 0x08

        // Print the current instruction data
        $display("Fetched Instruction: %h", d_inst_data);

        // Finish simulation
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk; // Toggle clock every 5 time units (200Mhz)
endmodule