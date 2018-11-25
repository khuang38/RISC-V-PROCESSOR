import rv32i_types::*;

module l2_cache
(
    input clk,

    /* Signals from Arbiter */
    input rv32i_word mem_address,
    input logic [255:0] mem_wdata,
    input mem_read,
    input mem_write,

    /* Signals from P-memory */
    input pmem_resp,
    input [255:0] pmem_rdata,

    /* Signals to P-memory */
    output rv32i_word pmem_address,
    output logic [255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,

    /* Signals to Arbiter */
    output logic mem_resp,
    output [255:0] mem_rdata,
	 
	output logic is_hit
    );

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

assign is_hit = hit_0 | hit_1;

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

l2_cache_datapath datapath
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


endmodule : l2_cache
