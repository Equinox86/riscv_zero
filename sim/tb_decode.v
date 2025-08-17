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
        .ALU_B_mux(ALU_B_mux)
    );

    initial begin
        $dumpfile("tb_decode.vcd");
        $dumpvars(0, tb_decode);

        // Load test instructions into memory

        reset = 1;
        #10 reset = 0;
    end

    always #5 clk = ~clk;

endmodule