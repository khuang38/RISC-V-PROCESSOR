module global_predictor (
	input clk,
	input[31:0] read_pc,
	output logic prediction,
	
	input[31:0] write_pc,
	input	write,
	input write_value,
	output logic is_correct
);

logic [1:0] branch_history_table [255:0]; // 2^8
logic [1:0] pattern_history_table [255:0]; // 2^8
logic [7:0] global_history;

logic [7:0] read_idx, write_idx, read_pht_idx, write_pht_idx;
logic [1:0] read_history, write_history;
assign read_idx = read_pc[9:2];
assign write_idx = write_pc[9:2];
assign read_history = branch_history_table[read_idx];
assign write_history = branch_history_table[write_idx];
assign read_pht_idx = {read_pc[5:2], global_history[7:6], read_history[1:0]};
assign write_pht_idx = {write_pc[5:2], global_history[7:6], write_history[1:0]};

/* 00 SNT 01 WNT 10 WT 11 ST */ 

initial
begin
    for (int i = 0; i < $size(branch_history_table); i++) begin
        branch_history_table[i] = 2'b10;
    end
	 for (int i = 0; i < $size(pattern_history_table); i++) begin
        pattern_history_table[i] = 2'b10;
    end
	 global_history = 8'h0;
end

/* high bit => recent */
always_ff @(posedge clk)
begin
	if (write == 1) begin
		branch_history_table[write_idx] <= {write_value, branch_history_table[write_idx][1]};
		if(write_value && pattern_history_table[write_pht_idx] != 2'b11)begin
			pattern_history_table[write_pht_idx] <= pattern_history_table[write_pht_idx] + 2'b01;
		end
		if(!write_value && pattern_history_table[write_pht_idx] != 2'b00)begin
			pattern_history_table[write_pht_idx] <= pattern_history_table[write_pht_idx] - 2'b01;
		end
		global_history <= {write_value, global_history[7:1]};
   end
end

assign prediction = pattern_history_table[read_pht_idx][1];
assign is_correct = write_value == pattern_history_table[write_pht_idx][1];

endmodule: global_predictor