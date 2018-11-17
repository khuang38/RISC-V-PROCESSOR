module data_forward_unit
(
	input mem_load_regfile,
	input[4:0] mem_rd,
	input wb_load_regfile,
	input[4:0] wb_rd,
	input[4:0] exe_rs1,
	input[4:0] exe_rs2,
	output logic [1:0] alufwdmux1_sel,
	output logic [1:0] alufwdmux2_sel
);

always_comb
begin
	alufwdmux1_sel = 2'h0;
	alufwdmux2_sel = 2'h0;
	
	if(mem_load_regfile & (mem_rd !=0) & (mem_rd == exe_rs1) ) begin
		alufwdmux1_sel = 2'h1;
	end else if(wb_load_regfile & (wb_rd != 0) & (wb_rd == exe_rs1)) begin
		alufwdmux1_sel = 2'h2;
	end
	
	if(mem_load_regfile & (mem_rd !=0) & (mem_rd == exe_rs2) ) begin
		alufwdmux2_sel = 2'h1;
	end else if(wb_load_regfile & (wb_rd != 0) & (wb_rd == exe_rs2)) begin
		alufwdmux2_sel = 2'h2;
	end
end

endmodule: data_forward_unit