module perf_counter
(
	input clk,
   input[4:0] read_src,
	output logic[31:0] read_data,
	input l1i_hit,
	input l1d_hit,
	input l2_hit,
	input l1i_read_or_write,
	input l1d_read_or_write,
	input l2_read_or_write,
	input is_branch,
	input br_en,
	input is_stall
);

logic [31:0] data [32];
logic l1i_last_miss, l1d_last_miss, l2_last_miss;
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 32'b0;
    end
	 l1i_last_miss = 0;
	 l1d_last_miss = 0;
	 l2_last_miss = 0;
end

always_comb
begin
    read_data = data[read_src];
end

/*
0 l1i hit
1 l1i miss
2 l1d hit
3 l1d miss
4 l2 hit
5 l2 miss
6 branch cnt
7 mispredict cnt
8 stalls
*/

always_ff @(posedge clk)
begin
	l1i_last_miss <= l1i_read_or_write & (~l1i_hit);
	l1d_last_miss <= l1d_read_or_write & (~l1d_hit);
	l2_last_miss <= l2_read_or_write & (~l2_hit);
	data[0] <= (l1i_read_or_write & l1i_hit & (~l1i_last_miss)) ? data[0] + 1 : data[0];
	data[1] <= (l1i_read_or_write & (~l1i_hit) & (~l1i_last_miss)) ? data[1] + 1 : data[1];
	data[2] <= (l1d_read_or_write & l1d_hit & (~l1d_last_miss)) ? data[2] + 1 : data[2];
	data[3] <= (l1d_read_or_write & (~l1d_hit) & (~l1d_last_miss)) ? data[3] + 1 : data[3];
	data[4] <= (l2_read_or_write & l2_hit & (~l2_last_miss)) ? data[4] + 1 : data[4];
	data[5] <= (l2_read_or_write & (~l2_hit) & (~l2_last_miss)) ? data[5] + 1 : data[5];
	
	data[6] <= is_branch ? data[6] + 1 : data[6];
	data[7] <= (is_branch & br_en) ? data[7] + 1: data[7];
	data[8] <= is_stall ? data[8] + 1 : data[8];
end


endmodule : perf_counter
