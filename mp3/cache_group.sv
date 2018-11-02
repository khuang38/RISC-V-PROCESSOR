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
    output [255:0] pmem_wdata
);

// Internal Signals Instantiation
logic i_resp, i_write, i_read;
logic [255:0] i_wdata;
logic [31:0] i_addr;
logic [255:0] i_rdata;

logic d_resp, d_write, d_read;
logic [255:0] d_wdata;
logic [31:0] d_addr;
logic  [255:0] d_rdata;


cache instruct_cache
(
    .clk,
    .cmem_resp(cmem_resp_a),
    .cmem_rdata(cmem_rdata_a),
    .cmem_read(cmem_read_a),
    .cmem_write(cmem_write_a),
    .cmem_byte_enable(cmem_byte_enable_a),
    .cmem_address(cmem_address_a),
    .cmem_wdata(cmem_wdata_a),

    .pmem_resp(i_resp),
    .pmem_rdata(i_rdata),
    .pmem_read(i_read),
    .pmem_write(i_write),
    .pmem_address(i_addr),
    .pmem_wdata(i_wdata)
);


cache data_cache
(
    .clk,
    .cmem_resp(cmem_resp_b),
    .cmem_rdata(cmem_rdata_b),
    .cmem_read(cmem_read_b),
    .cmem_write(cmem_write_b),
    .cmem_byte_enable(cmem_byte_enable_b),
    .cmem_address(cmem_address_b),
    .cmem_wdata(cmem_wdata_b),

    .pmem_resp(d_resp),
    .pmem_rdata(d_rdata),
    .pmem_read(d_read),
    .pmem_write(d_write),
    .pmem_address(d_addr),
    .pmem_wdata(d_wdata)
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
    .d_resp,
    .d_write,
    .d_read,
    .d_wdata,
    .d_addr,
    .d_rdata,

    .pmem_resp,
    .pmem_rdata,
    .pmem_read,
    .pmem_write,
    .pmem_address,
    .pmem_wdata
);

endmodule : cache_group
