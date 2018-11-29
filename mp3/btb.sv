module btb
(
	input clk,
	input[31: 0] input_pc,
	input[31: 0] input_ins,
	input read,
	output logic[31:0] output_pc,
	output logic btb_resp
);
 /* Signals from Arbiter */
 logic [31:0] mem_address;
 logic [31:0] mem_rdata;
 logic mem_resp;
 logic mem_read;
 assign mem_address = input_pc;
 assign output_pc = mem_rdata;
 assign btb_resp = mem_resp;
 assign mem_read = read;
 
 logic pmem_resp;
 logic [31:0] pmem_address;
 logic [31:0] pmem_rdata; 
 logic pmem_read; // ignore
 logic pmem_write; // ignore
 
 logic [31:0] b_imm;
 assign b_imm = {{20{input_ins[31]}}, input_ins[7], input_ins[30:25], input_ins[11:8], 1'b0};
 
 assign pmem_resp = 1;
 assign pmem_rdata = b_imm + input_pc;
 
 
 logic [31:0] mem_wdata; // useless
 logic mem_write;
 assign mem_wdata = 0;
 assign mem_write = 0;
 
 
 logic [31:0] pmem_wdata; // useless
 
 

logic hit_0, hit_1;
logic valid_out_0, dirty_out_0;
logic valid_out_1, dirty_out_1;
logic lru_out;
logic load_data_0, load_tag_0, load_valid_0, load_dirty_0;
logic load_data_1, load_tag_1, load_valid_1, load_dirty_1;

logic valid_in, dirty_in, lru_in;
logic way_sel;
logic load_lru;

logic [1:0] pmem_sel;
logic data_sel;
logic load_pmem_wdata;



cache_control control
(
    .clk,
    .mem_byte_enable(4'b1111),
    .mem_read,
    .mem_write,
    .pmem_resp,
    .pmem_read,
    .pmem_write,
    .mem_resp,
    .hit_0,
    .hit_1,
    .valid_out_0,
    .dirty_out_0,
    .valid_out_1,
    .dirty_out_1,
    .lru_out,
    .load_data_0,
    .load_tag_0,
    .load_valid_0,
    .load_dirty_0,
    .load_data_1,
    .load_tag_1,
    .load_valid_1,
    .load_dirty_1,
    .valid_in,
    .dirty_in,
    .way_sel,
    .load_lru,
    .lru_in,
    .pmem_sel,
    .load_pmem_wdata,
    .data_sel
    );

btb_cache_datapath datapath
(
    .clk,
    .mem_address,
    .mem_wdata,
    .pmem_rdata,
    .load_data_0,
    .load_tag_0,
    .load_valid_0,
    .load_dirty_0,
    .load_data_1,
    .load_tag_1,
    .load_valid_1,
    .load_dirty_1,
    .valid_in,
    .dirty_in,
    .way_sel,
    .load_lru,
    .lru_in,
    .pmem_sel,
    .data_sel,
	 .load_pmem_wdata,
    .pmem_address,
    .pmem_wdata,
    .mem_rdata,
    .hit_0,
    .hit_1,
    .valid_out_0,
    .dirty_out_0,
    .valid_out_1,
    .dirty_out_1,
    .lru_out
    );

endmodule: btb