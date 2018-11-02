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


// TODO::


endmodule : cache
