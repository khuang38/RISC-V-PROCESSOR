// This file is modified to accomodate the l2 cache functionalities
import rv32i_types::*;

module l2_cache_datapath
(
    input clk,

    /* Signals from Arbiter */
    input rv32i_word mem_address,       // Should be taking pmem_address from arbiter
    input [255:0] mem_wdata,      // Should be taking pmem_wdata from arbiter

    /* Signals from P-memory */
    input [255:0] pmem_rdata,

    /* Signals from Cache Control */
    input logic load_data_0,
    input logic load_tag_0,
    input logic load_valid_0,
    input logic load_dirty_0,

    input logic load_data_1,
    input logic load_tag_1,
    input logic load_valid_1,
    input logic load_dirty_1,

    input logic load_data_2,
    input logic load_tag_2,
    input logic load_valid_2,
    input logic load_dirty_2,

    input logic load_data_3,
    input logic load_tag_3,
    input logic load_valid_3,
    input logic load_dirty_3,

    input logic valid_in,
    input logic dirty_in,
    input logic [1:0] way_sel,

    input logic load_lru,
    input logic [2:0] lru_in,

    input logic [2:0] pmem_sel,
    input logic data_sel,
	input logic load_pmem_wdata,

    /* Signals to P-memory */
    output rv32i_word pmem_address,
    output logic [255:0] pmem_wdata,

    /* Signals to Arbiter */
    output logic [255:0] mem_rdata,

    /* Signals generated by Cache Ways */
    output logic hit_0,
    output logic hit_1,
    output logic hit_2,
    output logic hit_3,

    output logic valid_out_0,
    output logic dirty_out_0,

    output logic valid_out_1,
    output logic dirty_out_1,

    output logic valid_out_2,
    output logic dirty_out_2,

    output logic valid_out_3,
    output logic dirty_out_3,

    output logic [2:0] lru_out
    );

/* All the necesssary internal signals */
logic [3:0] index;      // Modified to accomodate longer L2_Cache
logic [22:0] tag_in;
logic [22:0] tag_0, tag_1, tag_2, tag_3;
logic [255:0] data_0, data_1, data_2, data_3;
logic [255:0] cache_mux_out;
// logic [255:0] write_cache_out;
logic [255:0] data_in;

/* Signals assignment */
assign tag_in = mem_address[31:9];
assign index = mem_address[8:5];

/*********************/
/* Assignment for L2 */
// assign mem_rdata = cache_mux_out;
// assign write_cache_out = mem_wdata;

/* Assignment for physical memory signals */
//assign pmem_wdata = cache_mux_out;


/*******************************/
/* LRU Bits:  L2    L1     L0  */
/* WAY:      C/D   A/B   AB/CD */
/*******************************/

/**************************/
/* WAY Notation: A B C D  */
/* WAY Number:   0 1 2 3  */
/**************************/
assign pmem_wdata = mem_rdata;
/*
register #(.width(256)) pmem_reg
(
	.clk,
	.load(load_pmem_wdata),
	.in(mem_rdata),
	.out(pmem_wdata)
);
*/

/* The cache way 0 */
l2_array data_array0
(
    .clk,
    .write(load_data_0),
    .index,
    .datain(data_in),
    .dataout(data_0)
    );

l2_array #(.width(23)) tag_array0
(
	.clk,
	.write(load_tag_0),
	.index,
	.datain(tag_in),
	.dataout(tag_0)
    );

l2_array #(.width(1)) valid_array0
(
    .clk,
    .write(load_valid_0),
    .index,
    .datain(valid_in),
    .dataout(valid_out_0)
    );

l2_array #(.width(1)) dirty_array0
(
    .clk,
    .write(load_dirty_0),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_0)
    );

comparator #(.width(23))compare_0
(
    .a(tag_in),
    .b(tag_0),
    .valid_bit(valid_out_0),
    .equal(hit_0)
    );


/* The cache way 1 */
l2_array data_array1
(
    .clk,
    .write(load_data_1),
    .index,
    .datain(data_in),
    .dataout(data_1)
    );

l2_array #(.width(23)) tag_array1
(
	.clk,
	.write(load_tag_1),
	.index,
	.datain(tag_in),
	.dataout(tag_1)
    );

l2_array #(.width(1)) valid_array1
(
    .clk,
    .write(load_valid_1),
    .index,
    .datain(valid_in),
    .dataout(valid_out_1)
    );

l2_array #(.width(1)) dirty_array1
(
    .clk,
    .write(load_dirty_1),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_1)
    );

comparator #(.width(23))compare_1
(
    .a(tag_in),
    .b(tag_1),
    .valid_bit(valid_out_1),
    .equal(hit_1)
    );


/* The cache way 2 */
l2_array data_array2
(
    .clk,
    .write(load_data_2),
    .index,
    .datain(data_in),
    .dataout(data_2)
    );

l2_array #(.width(23)) tag_array2
(
	.clk,
	.write(load_tag_2),
	.index,
	.datain(tag_in),
	.dataout(tag_2)
    );

l2_array #(.width(1)) valid_array2
(
    .clk,
    .write(load_valid_2),
    .index,
    .datain(valid_in),
    .dataout(valid_out_2)
    );

l2_array #(.width(1)) dirty_array2
(
    .clk,
    .write(load_dirty_2),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_2)
    );

comparator #(.width(23))compare_2
(
    .a(tag_in),
    .b(tag_2),
    .valid_bit(valid_out_2),
    .equal(hit_2)
    );


/* The cache way 3 */
l2_array data_array3
(
    .clk,
    .write(load_data_3),
    .index,
    .datain(data_in),
    .dataout(data_3)
    );

l2_array #(.width(23)) tag_array3
(
	.clk,
	.write(load_tag_3),
	.index,
	.datain(tag_in),
	.dataout(tag_3)
    );

l2_array #(.width(1)) valid_array3
(
    .clk,
    .write(load_valid_3),
    .index,
    .datain(valid_in),
    .dataout(valid_out_3)
    );

l2_array #(.width(1)) dirty_array3
(
    .clk,
    .write(load_dirty_3),
    .index,
    .datain(dirty_in),
    .dataout(dirty_out_3)
    );

comparator #(.width(23)) compare_3
(
    .a(tag_in),
    .b(tag_3),
    .valid_bit(valid_out_3),
    .equal(hit_3)
    );


/* The LRU module extended to three bits for 4-Way L2-Cache */
l2_array #(.width(3)) lru_module
(
	.clk,
	.write(load_lru),
	.index,
	.datain(lru_in),
	.dataout(lru_out)
);

/* The cache way MUX - Modified for 4-Way L2-Cache */
mux4 #(.width(256)) cache_way_mux
(
    .sel(way_sel),
    .a(data_0),
    .b(data_1),
    .c(data_2),
    .d(data_3),
    .f(mem_rdata)
    );

/* Physical Memory Address Mux */
/* Physical Memory Address Mux */
mux8 pmem_add_mux
(
  .sel(pmem_sel),
  .i0({mem_address[31:5], 5'b00000}),
  .i1({tag_0, index, 5'b00000}),
  .i2({tag_1, index, 5'b00000}),
  .i3({tag_2, index, 5'b00000}),
  .i4({tag_3, index, 5'b00000}),
  .i5(32'hXXXXXXXX),
  .i6(32'hXXXXXXXX),
  .i7(32'hXXXXXXXX),
  .f(pmem_address)
  );

/* Select what data should be written into cacheline */
mux2 #(.width(256)) data_mux
(
    .sel(data_sel),
    .a(pmem_rdata),
    .b(mem_wdata),
    .f(data_in)
    );

endmodule : l2_cache_datapath
