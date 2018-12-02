module tournament_predictor (
	input clk,
	input[31:0] read_pc,
	output logic prediction,
	
	input[31:0] write_pc,
	input	write,
	input write_value
);
logic global_prediction, local_prediction;
logic global_is_correct, local_is_correct;

logic [1:0] pattern_history_table [255:0]; // 2^8

logic [7:0] read_idx, write_idx;
logic [1:0] read_history, write_history;
assign read_idx = read_pc[9:2];
assign write_idx = write_pc[9:2];
/* 10 11 => global 00 01 => local*/
initial
begin
	 for (int i = 0; i < $size(pattern_history_table); i++) begin
        pattern_history_table[i] = 2'b10;
    end
end

always_ff @(posedge clk)
begin
	if (write == 1) begin
		if(global_is_correct && !local_is_correct && pattern_history_table[write_idx] != 2'b11)begin
			pattern_history_table[write_idx] <= pattern_history_table[write_idx] + 2'b01;
		end
		if(!global_is_correct && local_is_correct && pattern_history_table[write_idx] != 2'b00)begin
			pattern_history_table[write_idx] <= pattern_history_table[write_idx] - 2'b01;
		end
   end
end

global_predictor gp(
	.clk,
	.read_pc,
	.prediction(global_prediction),
	.is_correct(global_is_correct),
	.write_pc,
	.write,
	.write_value
);

local_predictor lp(
	.clk,
	.read_pc,
	.prediction(local_prediction),
	.is_correct(local_is_correct),
	.write_pc,
	.write,
	.write_value
);

assign prediction = pattern_history_table[read_idx][1] ? global_prediction : local_prediction;

endmodule: tournament_predictor