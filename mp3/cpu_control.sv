import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module control_rom
(
input rv32i_opcode opcode,
/* ... other inputs ... */
//input logic [2:0] funct3,
//input logic [6:0] funct7,
input rv32i_word ,
output rv32i_control_word ctrl
);


always_comb
begin
/*Default assignments */
ctrl.opcode = opcode;
ctrl.aluop = alu_add;
ctrl.regfilemux_sel = 4'b0000;
ctrl.load_regfile = 1'b0;
ctrl.mem_write = 1'b0;
ctrl.mem_write = 1'b0;
ctrl.pcmux_sel = 1'b0;
ctrl.cmpmux_sel = 1'b0;
ctrl.cmp_op = beq;
ctrl.alumux1_sel = 4'b0000;
ctrl.alumux2_sel = 5'b00000;


/* Assign control signals based on opcode */
case(opcode)
       op_auipc: begin
       ctrl.aluop = alu_add;
		 ctrl.alumux1_sel = 4'b0001;
		 ctrl.alumux2_sel = 5'b00001;
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.regfilemux_sel = 4'b0001;
		 ctrl.load_regfile = 1'b1;
       end
		 op_lui: begin
		 ctrl.aluop = alu_add;
		 ctrl.alumux1_sel = 4'b0010;
		 ctrl.alumux2_sel = 5'b00001;
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.regfilemux_sel = 4'b0010;
		 ctrl.load_regfile = 1'b1;
		 end
		 op_load: begin
		 ctrl.aluop = alu_add;
		 ctrl.alumux1_sel = 4'b0000;
		 ctrl.alumux2_sel = 5'b00000;
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b1;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.regfilemux_sel = 4'b0000;
		 ctrl.load_regfile = 1'b1;
		 end
		 op_store: begin
		 ctrl.aluop = alu_add;
		 ctrl.alumux1_sel = 4'b0000;
		 ctrl.alumux2_sel = 5'b00011;
		 ctrl.mem_write = 1'b1;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.load_regfile = 1'b0;
		 end
		 op_imm: begin /*ADDI, XORI, ORI, ANDI, SLLI, SRLI*/
		 ctrl.aluop = alu_ops'(funct3);
		 ctrl.alumux1_sel = 4'b0000;
		 ctrl.alumux2_sel = 5'b00001;
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.regfilemux_sel = 4'b0000;
		 ctrl.load_regfile = 1'b1;
		 end
		 op_reg: begin /*ADD, SLL, XOR, SRL, OR, AND*/
		 ctrl.aluop = alu_ops'(funct3);
		 ctrl.alumux1_sel = 4'b0000;
		 ctrl.alumux2_sel = 5'b00100;
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b0;
		 ctrl.regfilemux_sel = 4'b0000;
		 ctrl.load_regfile = 1'b1;
		 end
		 op_br: begin /*BEQ, BNE, BLT, BGE, BLTU, BGEU*/
		 ctrl.aluop = alu_add;
		 ctrl.alumux1_sel = 4'b0001;
		 ctrl.alumux2_sel = 5'b00010;
		 ctrl.cmpmux_sel = 1'b0;
		 ctrl.cmp_op = branch_funct3_t'(funct3);
		 ctrl.mem_write = 1'b0;
		 ctrl.mem_read = 1'b0;
		 ctrl.pcmux_sel = 1'b1;
		 ctrl.load_regfile = 1'b0;
		 end
		 
		 
       
default: begin
ctrl = 0; /* Unknown opcode, set control word to zero */
end

endcase
end
endmodule : control_rom





