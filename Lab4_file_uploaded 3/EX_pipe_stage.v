`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] ALU_Control;
    wire [31:0] input_a, input_b, input_b_2;
    // Write your code here
    assign alu_in2_out = input_b;
    
    ALU alu_unit(
        .a(input_a),
        .b(input_b_2),
        .alu_control(ALU_Control),
        .alu_result(alu_result)
    );
    
    ALUControl alu_control_unit(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control)
    );
    
    mux4 #() input_a_mux
    (
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(0),
        .sel(Forward_A),
        .y(input_a)
    );
    
    mux4 #() input_b_mux
    (
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(0),
        .sel(Forward_B),
        .y(input_b)
    );
    
    mux2 #() input_b_mux_2
    (
        .a(input_b),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(input_b_2)
    );
       
endmodule
