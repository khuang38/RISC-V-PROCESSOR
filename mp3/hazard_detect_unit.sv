module hazard_detect_unit
(
	input exe_mem_read,
	input[4:0] exe_rd,
	input[4:0] id_rs1,
	input[4:0] id_rs2,
	output logic insert_bubble
);

always_comb
begin
	if(exe_mem_read & exe_rd != 0 & ( (exe_rd == id_rs1) | (exe_rd == id_rs2) ))begin
		insert_bubble = 1;
	end else begin
		insert_bubble = 0;
	end
end

endmodule: hazard_detect_unit