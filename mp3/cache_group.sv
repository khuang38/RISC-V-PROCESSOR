// Updated on Nov 16 for adding L2 cache in the module
module cache_group
(
    input         clk,

    output         cmem_resp_a,
    output [31:0]  cmem_rdata_a,
    input          cmem_read_a,
    input          cmem_write_a,
    input [3:0]    cmem_byte_enable_a,
    input [31:0]   cmem_address_a,
    input [31:0]   cmem_wdata_a,

	output         cmem_resp_b,
    output [31:0]  cmem_rdata_b,
    input          cmem_read_b,
    input          cmem_write_b,
    input [3:0]    cmem_byte_enable_b,
    input [31:0]   cmem_address_b,
    input [31:0]   cmem_wdata_b,

    input          pmem_resp,
    input [255:0]  pmem_rdata,
    output         pmem_read,
    output         pmem_write,
    output [31:0]  pmem_address,
    output [255:0] pmem_wdata,

	output logic l1i_hit,
	output logic l1d_hit,
	output logic l2_hit,
	output logic l2_read_or_write
);

// Signals from L1-Caches to L1-WB
logic i_resp, i_write, i_read;
logic [255:0] i_wdata;
logic [31:0] i_addr;
logic [255:0] i_rdata;

logic d_resp, d_write, d_read;
logic [255:0] d_wdata;
logic [31:0] d_addr;
logic [255:0] d_rdata;

logic d_wb_resp, d_wb_write, d_wb_read;
logic [255:0] d_wb_wdata;
logic [31:0] d_wb_addr;
logic [255:0] d_wb_rdata;

// Signals between Arbiter and L2-Cache
logic ab_resp, ab_read, ab_write;
logic [255:0] ab_rdata;
logic [31:0] ab_address;
logic [255:0] ab_wdata;

// Signals between L2-Cache WB
logic l2_resp, l2_read, l2_write;
logic [255:0] l2_rdata;
logic [31:0] l2_address;
logic [255:0] l2_wdata;


cache instruct_cache
(
    .clk,
    .mem_resp(cmem_resp_a),
    .mem_rdata(cmem_rdata_a),
    .mem_read(cmem_read_a),
    .mem_write(cmem_write_a),
    .mem_byte_enable(cmem_byte_enable_a),
    .mem_address(cmem_address_a),
    .mem_wdata(cmem_wdata_a),

    .pmem_resp(i_resp),
    .pmem_rdata(i_rdata),
    .pmem_read(i_read),
    .pmem_write(i_write),
    .pmem_address(i_addr),
    .pmem_wdata(i_wdata),
	 .is_hit(l1i_hit)
);

cache data_cache
(
    .clk,
    .mem_resp(cmem_resp_b),
    .mem_rdata(cmem_rdata_b),
    .mem_read(cmem_read_b),
    .mem_write(cmem_write_b),
    .mem_byte_enable(cmem_byte_enable_b),
    .mem_address(cmem_address_b),
    .mem_wdata(cmem_wdata_b),

    .pmem_resp(d_resp),
    .pmem_rdata(d_rdata),
    .pmem_read(d_read),
    .pmem_write(d_write),
    .pmem_address(d_addr),
    .pmem_wdata(d_wdata),
	 .is_hit(l1d_hit)
);

write_evict_buffer data_wb(
    .clk,

    // Connections between cache and the write eviction buffer
    .cmem_read(d_read),
    .cmem_write(d_write),
    .cmem_address(d_addr),
    .cmem_wdata(d_wdata),
    .cmem_rdata(d_rdata),
    .cmem_resp(d_resp),

    // Connections between write eviction buffer and the 'physical memory' seen by WB
    .pmem_read(d_wb_read),
    .pmem_write(d_wb_write),
    .pmem_address(d_wb_addr),
    .pmem_wdata(d_wb_wdata),
    .pmem_rdata(d_wb_rdata),
    .pmem_resp(d_wb_resp)
);

arbiter arbiter
(
    .clk,

    .i_resp,
    .i_write,
    .i_read,
    .i_wdata,
    .i_addr,
    .i_rdata,

    // Signals for data cache
    .d_resp(d_wb_resp),
    .d_write(d_wb_write),
    .d_read(d_wb_read),
    .d_wdata(d_wb_wdata),
    .d_addr(d_wb_addr),
    .d_rdata(d_wb_rdata),

    .pmem_resp(ab_resp),
    .pmem_rdata(ab_rdata),
    .pmem_read(ab_read),
    .pmem_write(ab_write),
    .pmem_address(ab_address),
    .pmem_wdata(ab_wdata)
);


assign l2_read_or_write = ab_read | ab_write;

logic l2_latch_resp;
logic l2_latch_write;
logic l2_latch_read;
logic[31:0] l2_latch_address;
logic[255:0] l2_latch_rdata;
logic[255:0] l2_latch_wdata;

memory_latch l2_latch(
	 .clk,
    .cmem_read(ab_read),
    .cmem_write(ab_write),
    .cmem_address(ab_address),
    .cmem_wdata(ab_wdata),
    .cmem_rdata(ab_rdata),
    .cmem_resp(ab_resp),
	 
	 .pmem_read(l2_latch_read),
    .pmem_write(l2_latch_write),
    .pmem_address(l2_latch_address),
    .pmem_wdata(l2_latch_wdata),
    .pmem_rdata(l2_latch_rdata),
    .pmem_resp(l2_latch_resp)
	);

// Added to incorporate L2-Cache
l2_cache l2_cache
(
    .clk,
    .mem_resp(l2_latch_resp),
    .mem_rdata(l2_latch_rdata),
    .mem_read(l2_latch_read),
    .mem_write(l2_latch_write),
    .mem_address(l2_latch_address),
    .mem_wdata(l2_latch_wdata),

    .pmem_resp(l2_resp),
    .pmem_rdata(l2_rdata),
    .pmem_read(l2_read),
    .pmem_write(l2_write),
    .pmem_address(l2_address),
    .pmem_wdata(l2_wdata),
	.is_hit(l2_hit)
);

// Added WB in between L2-Cache and Physical Memory
write_evict_buffer l2_wb(
    .clk,

    // Connections between cache and the write eviction buffer
    .cmem_read(l2_read),
    .cmem_write(l2_write),
    .cmem_address(l2_address),
    .cmem_wdata(l2_wdata),
    .cmem_rdata(l2_rdata),
    .cmem_resp(l2_resp),

    // Connections between write eviction buffer and the 'physical memory' seen by WB
    .pmem_read,
    .pmem_write,
    .pmem_address,
    .pmem_wdata,
    .pmem_rdata,
    .pmem_resp
);

endmodule : cache_group
