// This file is modified to accomodate the l2 cache functionalities
import rv32i_types::*;

module btb_cache_datapath
(
    input clk,

    /* Signals from Arbiter */
    input rv32i_word mem_address,       // Should be taking pmem_address from arbiter
    input logic [31:0] mem_wdata,      // Should be taking pmem_wdata from arbiter

    /* Signals from P-memory */
    input [31:0] pmem_rdata,

    /* Signals from Cache Control */
    input logic load_data_0,
    input logic load_tag_0,
    input logic load_valid_0,
    input logic load_dirty_0,

    input logic load_data_1,
    input logic load_tag_1,
    input logic load_valid_1,
    input logic load_dirty_1,

    input logic valid_in,
    input logic dirty_in,
    input logic way_sel,

    input logic load_lru,
    input logic lru_in,

    input logic [1:0] pmem_sel,
    input logic data_sel,
	input logic load_pmem_wdata,

    /* Signals to P-memory */
    output rv32i_word pmem_address,
    output [31:0] pmem_wdata,

    /* Signals to Arbiter */
    output [31:0] mem_rdata,

    /* Signals generated by Cache Ways */
    output logic hit_0,
    output logic hit_1,
    output logic valid_out_0,
    output logic dirty_out_0,
    output logic valid_out_1,
    output logic dirty_out_1,

    output logic lru_out
    );

/* All the necesssary internal signals */
logic [2:0] index;
logic [4:0] byte_offset;
logic [23:0] tag_in;
logic [23:0] tag_0, tag_1;
logic [31:0] data_0, data_1;
logic [31:0] cache_mux_out;
// logic [31:0] write_cache_out;
logic [31:0] data_in;

/* Signals assignment */
assign tag_in = mem_address[31:5];
assign index = mem_address[4:2];

/*********************/
/* Assignment for L2 */
// assign mem_rdata = cache_mux_out;
// assign write_cache_out = mem_wdata;

/* Assignment for physical memory signals */
//assign pmem_wdata = cache_mux_out;

register #(.width(32)) pmem_reg
(
	.clk,
	.load(load_pmem_wdata),
	.in(mem_rdata),
	.out(pmem_wdata)
);

/* The cache way 0 */
array #(.width(32)) data_array0
(
    .clk,
    .write(load_data_0),
    .index,
    .datain(data_in),
    .dataout(data_0)
    );

array #(.width(27)) tag_array0
(
	.clk,
	.write(load_tag_0),
	.index,
	.datain(tag_in),
	.dataout(tag_0)
    );

array #(.width(1)) valid_array0
(
    .clk,
    .write(load_valid_0),
    .index,
    .datain(valid_in),
    .dataout(valid_out_0)
    );

array #(.width(1)) dirty_array0
(
    .clk,
    .write(load_dirty_0),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_0)
    );

comparator compare_0
(
    .a(tag_in),
    .b(tag_0),
    .valid_bit(valid_out_0),
    .equal(hit_0)
    );


/* The cache way 1 */
array #(.width(32)) data_array1
(
    .clk,
    .write(load_data_1),
    .index,
    .datain(data_in),
    .dataout(data_1)
    );

array #(.width(27)) tag_array1
(
	.clk,
	.write(load_tag_1),
	.index,
	.datain(tag_in),
	.dataout(tag_1)
    );

array #(.width(1)) valid_array1
(
    .clk,
    .write(load_valid_1),
    .index,
    .datain(valid_in),
    .dataout(valid_out_1)
    );

array #(.width(1)) dirty_array1
(
    .clk,
    .write(load_dirty_1),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_1)
    );

comparator compare_1
(
    .a(tag_in),
    .b(tag_1),
    .valid_bit(valid_out_1),
    .equal(hit_1)
    );

/* The LRU module */
array #(.width(1)) lru_module
(
	.clk,
	.write(load_lru),
	.index,
	.datain(lru_in),
	.dataout(lru_out)
);

/* The cache way MUX */
mux2 #(.width(32)) cache_way_mux
(
    .sel(way_sel),
    .a(data_0),
    .b(data_1),
    .f(mem_rdata)
    );

assign pmem_address = mem_address;

/* Select what data should be written into cacheline */
mux2 #(.width(32)) data_mux
(
    .sel(data_sel),
    .a(pmem_rdata),
    .b(mem_wdata),
    .f(data_in)
    );

endmodule : btb_cache_datapath
