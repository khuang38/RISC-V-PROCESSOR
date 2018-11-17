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
ctrl.pcmux_sel = 2'b00;
ctrl.cmpmux_sel = 1'b0;
ctrl.cmp_op = beq;
ctrl.alumux1_sel = 2'b00;
ctrl.alumux2_sel = 3'b000;
ctrl.mdr_sel = 3'b000;
ctrl.mem_byte_enable = 4'b1111;


/* Assign control signals based on opcode */
case(ctrl.opcode)
        op_auipc: begin
            ctrl.aluop = alu_add;
        	ctrl.alumux1_sel = 2'b01;
        	ctrl.alumux2_sel = 3'b001;
        	ctrl.mem_write = 1'b0;
        	ctrl.mem_read = 1'b0;
        	ctrl.pcmux_sel = 2'b00;
        	ctrl.regfilemux_sel = 2'b10;
        	ctrl.load_regfile = 1'b1;
        end

		op_lui: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b10;
    		ctrl.alumux2_sel = 3'b001;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 2'b00;
    		ctrl.regfilemux_sel = 2'b10;
    		ctrl.load_regfile = 1'b1;
		end

		op_load: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b000;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b1;
    		ctrl.pcmux_sel = 2'b00;
    		ctrl.regfilemux_sel = 2'b00;
    		ctrl.load_regfile = 1'b1;
			if (funct3 == 3'b000) /*LB*/
			    ctrl.mdr_sel = 3'b011;
			else if (funct3 == 3'b001) /*LH*/
	          ctrl.mdr_sel = 3'b001;
		  	else if (funct3 == 3'b010) /*LW*/
	          ctrl.mdr_sel = 3'b000;
			else if (funct3 == 3'b100) /*LBU*/
	          ctrl.mdr_sel = 3'b100;
			else if (funct3 == 3'b101) /*LHU*/
	          ctrl.mdr_sel = 3'b010;
		end

		op_store: begin
    		ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b011;
    		ctrl.mem_write = 1'b1;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 2'b00;
    		ctrl.load_regfile = 1'b0;
			if (funct3 == 3'b000) /*SB*/
			    ctrl.mem_byte_enable = 4'b0001;
			else if (funct3 == 3'b001) /*SH*/
	          ctrl.mem_byte_enable = 4'b0011;
		  	else if (funct3 == 3'b010) /*SW*/
	          ctrl.mem_byte_enable = 4'b1111;
		end

		op_imm: begin /*ADDI, XORI, ORI, ANDI, SLLI, SRLI*/
    		ctrl.aluop = alu_ops'(funct3);
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b000;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 2'b00;
    		ctrl.regfilemux_sel = 2'h2;
		   ctrl.load_regfile = 1'b1;
			if (funct7[5] && ctrl.aluop == alu_srl)
				 ctrl.aluop = alu_sra;
			if (funct3 == slt) begin
				ctrl.aluop = alu_add;
				ctrl.cmp_op = blt;
				ctrl.regfilemux_sel = 2'h1;
			end
			if (funct3 == sltu) begin
				ctrl.aluop = alu_add;
				ctrl.cmp_op = bltu;
				ctrl.regfilemux_sel = 2'h1;
			end
		end

		op_reg: begin /*ADD, SLL, XOR, SRL, OR, AND*/
    	   ctrl.aluop = alu_ops'(funct3);
        	ctrl.alumux1_sel = 2'b00;
        	ctrl.alumux2_sel = 3'b101;
        	ctrl.mem_write = 1'b0;
        	ctrl.mem_read = 1'b0;
        	ctrl.pcmux_sel = 2'b00;
        	ctrl.regfilemux_sel = 2'h2;
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
    		ctrl.pcmux_sel = 2'b01;
    		ctrl.load_regfile = 1'b0;
		end

		op_jal: begin /*JAL*/
		   ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b01;
    		ctrl.alumux2_sel = 3'b100;
    		ctrl.cmpmux_sel = 1'b0;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 2'b10;
    		ctrl.load_regfile = 1'b1;
			ctrl.regfilemux_sel = 2'h3;
		end

		op_jalr: begin /*JALR*/
		   ctrl.aluop = alu_add;
    		ctrl.alumux1_sel = 2'b00;
    		ctrl.alumux2_sel = 3'b000;
    		ctrl.cmpmux_sel = 1'b0;
    		ctrl.mem_write = 1'b0;
    		ctrl.mem_read = 1'b0;
    		ctrl.pcmux_sel = 2'b10;
    		ctrl.load_regfile = 1'b1;
			ctrl.regfilemux_sel = 2'h3;
		end

        default: begin
            ctrl = 0; /* Unknown opcode, set control word to zero */
        end

    endcase
	// for debug
    if(instruction == 32'h0)begin
$display("no ins");
    end
    case (ctrl.opcode)
        op_lui: begin
            $display("op_lui");
        end
        op_jal: begin
            $display("op_jal");
        end
        op_jalr: begin
            $display("op_jalr");
        end

        op_auipc: begin
            $display("op_auipc");
        end
        op_br: begin
            case (funct3)
            beq: $display("op_beq");
            bne: $display("op_bne");
            blt: $display("op_blt");
            bge: $display("op_bge");
            bltu: $display("op_bltu");
            bgeu: $display("op_bgeu");
            default: $display("unknown funct3");
            endcase // case (funct3)
        end
        op_load:  begin
            $display("op_load");
        end
        op_store:  begin
            $display("op_store");
        end
        op_reg: begin
            case (funct3)
            add: begin
                if(funct7[5]) $display("op_sub");
                else $display("op_add");
            end
            sll: $display("op_sll");
            slt: $display("op_slt");
            sltu: $display("op_sltu");
            axor: $display("op_axor");
            sr: begin
                if(funct7[5]) $display("op_sra");
                else $display("op_srl");
            end
            aor: $display("op_aor");
            aand: $display("op_aand");
            endcase // case (funct3)
        end
        op_imm: begin
            case (funct3)
            add: begin
                if(funct7[5]) $display("op_subi");
                else $display("op_addi");
            end
            sll: $display("op_slli");
            slt: $display("op_slti");
            sltu: $display("op_sltui");
            axor: $display("op_axori");
            sr: begin
                if(funct7[5]) $display("op_srai");
                else $display("op_srli");
            end
            aor: $display("op_aori");
            aand: $display("op_aandi");
            endcase // case (funct3)
        end
        default: $display("unknown opcode");
    endcase // case (opcode)
end

endmodule : control_rom
