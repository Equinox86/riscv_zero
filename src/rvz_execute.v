module riscv_zero_execute(
    input clk,
    input reset,
    input [63:0] pc_in,

    input [6:0] opcode,
    input [31:0] immediate,
    input [4:0]  reg_dest,
    input [63:0] rs1_data,
    input [63:0] rs2_data,
    input [6:0] funct7_out,
    input [2:0] funct3_out,

    // Control Unit Inputs
    input writeback_enable_in,
    input [1:0] writeback_source_in,
    input memory_access_in,
    input mem_wenable_in,
    input jump,
    input branch,
    input ALU_A_mux,
    input ALU_B_mux,
    input [3:0] ALU_op,

    // Execute control registers
    output wire pc_src,
    output wire [63:0] pc_target,

    output reg [63:0] pc_out,
    output reg writeback_enable_out,
    output reg [1:0] writeback_source_out,
    output reg memory_access_out,
    output reg mem_wenable_out,

    // Execute output Registers to Memory Access
    output reg [63:0] ALU_out,
    output reg [63:0] mem_write_data,
);

wire ALU_A_src[63:0] = ALU_A_mux ? pc_in : rs1_data;
wire ALU_B_src[63:0] = ALU_B_mux ? immediate : rs2_data;
wire ALU_result [63:0];

assign pc_src = (ALU_result[0] & branch) | jump;
assign pc_target = pc_in + immediate;

alu execute_alu (
    .a(ALU_A_src),
    .b(ALU_B_src),
    .operation(ALU_op),
    .result(ALU_result)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 64'h0;
        ALU_out <= 64'h0;
        pc_target <= 64'h0;
        pc_src <= 1'b0;
        writeback_enable <= 1'b0;
        writeback_source <= 2'b00;
        memory_access <= 1'b0;
        mem_wenable <= 1'b0;

    end else begin
        pc_out <= pc_in;
        writeback_enable_out <= writeback_enable_in;
        writeback_source_out <= writeback_source_in;
        mem_write_data <= rs2_data;
        mem_wenable_out <+ mem_wenable_in;
        ALU_out <= ALU_result;
    end

end

endmodule;