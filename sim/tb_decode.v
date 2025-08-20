module tb_decode;

    //
    // Module Inputs
    //

    reg clk;
    reg reset;
    reg [31:0] inst_data;
    reg [31:0] pc_in;

    // Register file writeback control
    reg reg_wenable;
    reg [4:0] reg_waddr;
    reg [63:0] reg_wdata;

    //
    // Module Outputs
    //

    // Decode registers to Execute
    wire [6:0] opcode;
    wire [31:0] immediate;
    wire [4:0]  reg_dest;
    wire [63:0] reg1_out;
    wire [63:0] reg2_out;
    wire [31:0] pc_out;
    wire [6:0] funct7; 
    wire [2:0] funct3;

    // Decode control registers
    wire writeback_enable;
    wire [1:0] writeback_source;
    wire mem_wenable;
    wire jump;
    wire branch;
    wire ALU_A_mux;
    wire ALU_B_mux;

    riscv_zero_decode uut (
        .clk(clk),
        .reset(reset),
        .inst_data(inst_data),
        .pc_in(pc_in),
        .reg_wenable(reg_wenable),
        .reg_waddr(reg_waddr),
        .reg_wdata(reg_wdata),
        .immediate(immediate),
        .reg_dest(reg_dest),
        .reg1_out(reg1_out),
        .reg2_out(reg2_out),
        .pc_out(pc_out),
        .writeback_enable(writeback_enable),
        .writeback_source(writeback_source),
        .mem_wenable(mem_wenable),
        .jump(jump),
        .branch(branch),
        .ALU_A_mux(ALU_A_mux),
        .ALU_B_mux(ALU_B_mux),
        .opcode(opcode),
        .funct3_out(funct3),
        .funct7_out(funct7)
    );

    reg [31:0] instruction_memory [0:36];
    integer i;
    initial begin
        $dumpfile("tb_decode.vcd");
        $dumpvars(0, tb_decode);
        clk = 0;
        pc_in = 0;

        // Load test instructions into memory
        $readmemh("../src/memory/imem.hex", instruction_memory);

        // Toggle Reset
        reset = 1;
        #4 reset = 0;
        for (i = 0; i < 36; i = i + 1) begin
            inst_data = instruction_memory[i];
            pc_in = i * 4;
            #4;
        end

        $finish(0);
    end

    always #2 clk = ~clk;

endmodule