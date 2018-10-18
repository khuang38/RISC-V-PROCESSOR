/* Import types defined in rv32i_types.sv */
import rv32i_types::*;

module control_rom
(
    input [31:0] instruction,
    /* ... other inputs ... */
    output rv32i_control_word ctrl
);

logic [2:0] funct3;
logic [6:0] funct7;
assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];

always_comb
begin
/*Default assignments */
ctrl.opcode = rv32i_opcode'(instruction[6:0]);
ctrl.aluop = alu_add;
ctrl.regfilemux_sel = 2'b00;
ctrl.load_regfile = 1'b0;
ctrl.mem_write = 1'b0;
ctrl.mem_write = 1'b0;
ctrl.pcmux_sel = 1'b0;
ctrl.cmpmux_sel = 1'b0;
ctrl.cmp_op = beq;
ctrl.alumux1_sel = 2'b00;
ctrl.alumux2_sel = 3'b000;


/* Assign control signals based on opcode */
case(ctrl.opcode)
        op_auipc: begin
            ctrl.aluop = alu_add;
        	ctrl.alumux1_sel = 2'b01;
        	ctrl.alumux2_sel = 3'b001;
        	ctrl.mem_write = 1'b0;
        	ctrl.mem_read = 1'b0;
        	ctrl.pcmux_sel = 1'b0;
        	ctrl.regfilemux_sel = 2'b01;
        	ctrl.load_regfile = 1'b1;
        end

		op_lui: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b10;
    		ctrl.alumux2_sel = 3'b001;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 1'b0;
    		ctrl.regfilemux_sel = 2'b10;
    		ctrl.load_regfile = 1'b1;
		end

		op_load: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b000;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b1;
    		ctrl.pcmux_sel = 1'b0;
    		ctrl.regfilemux_sel = 2'b00;
    		ctrl.load_regfile = 1'b1;
		end

		op_store: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b011;
    		ctrl.mem_write = 1'b1;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 1'b0;
    		ctrl.load_regfile = 1'b0;
		end

		op_imm: begin /*ADDI, XORI, ORI, ANDI, SLLI, SRLI*/
    		ctrl.aluop = alu_ops'(funct3);
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b001;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 1'b0;
    		ctrl.regfilemux_sel = 2'b00;
		    ctrl.load_regfile = 1'b1;
            if (funct7[5] && ctrl.aluop == alu_srl)
                ctrl.aluop = alu_sra;
		end

		op_reg: begin /*ADD, SLL, XOR, SRL, OR, AND*/
    	    ctrl.aluop = alu_ops'(funct3);
        	ctrl.alumux1_sel = 2'b00;
        	ctrl.alumux2_sel = 3'b100;
        	ctrl.mem_write = 1'b0;
        	ctrl.mem_read = 1'b0;
        	ctrl.pcmux_sel = 1'b0;
        	ctrl.regfilemux_sel = 2'b00;
        	ctrl.load_regfile = 1'b1;
            if (funct7[5] && ctrl.aluop == alu_add)
                ctrl.aluop = alu_sub;
            if (funct7[5] && ctrl.aluop == alu_srl)
                ctrl.aluop = alu_sra;
		end

		op_br: begin /*BEQ, BNE, BLT, BGE, BLTU, BGEU*/
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b01;
    		ctrl.alumux2_sel = 3'b010;
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
