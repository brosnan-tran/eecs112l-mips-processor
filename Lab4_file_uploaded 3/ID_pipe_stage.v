`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    wire [5:0] inst_31_26;
    wire reg_dst;
    wire branch;
    wire zero;
    wire mem_to_reg2, mem_read2, mem_write2, alu_src2, reg_write2;
    wire [1:0] alu_op2;
    wire control_sel;
   
    
    assign inst_31_26 = instr[31:26];
    assign jump_address = (instr[25:0] << 2);
    assign branch_address = (imm_value << 2) + pc_plus4;
    
    assign zero = ((reg1^reg2) == 32'd0) ? 1'b1 : 1'b0;
    assign branch_taken = branch & zero;
    assign control_sel = ~Data_Hazard | Control_Hazard;
    
    sign_extend sign_ex_inst (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value));
    
    control control_unit(
        .reset(reset),
        .opcode(inst_31_26),
        .reg_dst(reg_dst), 
        .mem_to_reg(mem_to_reg2),
        .alu_op(alu_op2),
        .mem_read(mem_read2),  
        .mem_write(mem_write2),
        .alu_src(alu_src2),
        .reg_write(reg_write2),
        .branch(branch),
        .jump(jump));
        
    register_file reg_file (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));
        
    mux2 #(.mux_width(5)) dest_reg_mux
    (
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg)
    );
    
    mux2 #(.mux_width(1)) mem_to_reg_mux
    (
        .a(mem_to_reg2),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_to_reg)
    );
    mux2 #(.mux_width(2)) alu_op_mux
    (
        .a(alu_op2),
        .b(2'b00),
        .sel(control_sel),
        .y(alu_op)
    );
    mux2 #(.mux_width(1)) mem_read_mux
    (
        .a(mem_read2),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_read)
    );
    mux2 #(.mux_width(1)) mem_write_mux
    (
        .a(mem_write2),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_write)
    );
    mux2 #(.mux_width(1)) alu_src_mux
    (
        .a(alu_src2),
        .b(1'b0),
        .sel(control_sel),
        .y(alu_src)
    );
    mux2 #(.mux_width(1)) reg_write_mux
    (
        .a(reg_write2),
        .b(1'b0),
        .sel(control_sel),
        .y(reg_write)
    );
       
endmodule
