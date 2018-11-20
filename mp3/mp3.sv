
module mp3
(
	 input clk,
    input          pmem_resp,
    input [255:0]  pmem_rdata,
    output         pmem_read,
    output         pmem_write,
    output [31:0]  pmem_address,
    output [255:0] pmem_wdata
);

   /* from IR/cmp to controller*/

   logic          cmem_resp_a;
   logic [31:0]   cmem_rdata_a;
   logic          cmem_read_a;
   logic          cmem_write_a;
   logic [3:0]    cmem_byte_enable_a;
   logic [31:0]   cmem_address_a;
   logic [31:0]   cmem_wdata_a;

   logic          cmem_resp_b;
   logic [31:0]   cmem_rdata_b;
   logic          cmem_read_b;
   logic          cmem_write_b;
   logic [3:0]    cmem_byte_enable_b;
   logic [31:0]   cmem_address_b;
   logic [31:0]   cmem_wdata_b;
	
	logic l1i_hit, l1d_hit, l2_hit, l2_read_or_write;


   cpu cpu
     (
      .clk(clk),
	   .cmem_resp_a,
      .cmem_rdata_a,
      .cmem_read_a,
      .cmem_write_a,
      .cmem_byte_enable_a,
      .cmem_address_a,
      .cmem_wdata_a,

      .cmem_resp_b,
      .cmem_rdata_b,
      .cmem_read_b,
      .cmem_write_b,
      .cmem_byte_enable_b,
      .cmem_address_b,
      .cmem_wdata_b,
		.l1i_hit,
		.l1d_hit,
		.l2_hit,
		.l2_read_or_write
      );

   cache_group cache_group
     (
      .clk,
      .cmem_resp_a,
      .cmem_rdata_a,
      .cmem_read_a,
      .cmem_write_a,
      .cmem_byte_enable_a,
      .cmem_address_a,
      .cmem_wdata_a,

      .cmem_resp_b,
      .cmem_rdata_b,
      .cmem_read_b,
      .cmem_write_b,
      .cmem_byte_enable_b,
      .cmem_address_b,
      .cmem_wdata_b,

      .pmem_resp,
      .pmem_address,
      .pmem_wdata,
      .pmem_rdata,
      .pmem_read,
      .pmem_write,
		
		.l1i_hit,
		.l1d_hit,
		.l2_hit,
		.l2_read_or_write
      );

endmodule : mp3
