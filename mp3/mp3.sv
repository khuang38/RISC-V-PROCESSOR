
module mp3
(
	input clk,
	/* Port A */
    input mem_resp_a,
    input [31:0] mem_rdata_a,
    output logic mem_read_a,
    output logic mem_write_a,
    output logic [3:0] mem_byte_enable_a,
    output logic [31:0] mem_address_a,
    output logic [31:0] mem_wdata_a,
	/* Port B */
	input mem_resp_b,
    input [31:0] mem_rdata_b,
    output logic mem_read_b,
    output logic mem_write_b,
    output logic [3:0] mem_byte_enable_b,
    output logic [31:0] mem_address_b,
    output logic [31:0] mem_wdata_b
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

   /* Assignment that we will be using for now */
   assign cmem_resp_a = mem_resp_a;
   assign cmem_rdata_a = mem_rdata_a;

   assign mem_read_a = cmem_read_a;
   assign mem_write_a = cmem_write_a;
   assign mem_byte_enable_a = cmem_byte_enable_a;
   assign mem_address_a = cmem_address_a;
   assign mem_wdata_a = cmem_wdata_a;

   assign cmem_resp_b = mem_resp_b;
   assign cmem_rdata_b = mem_rdata_b;

   assign mem_read_b = cmem_read_b;
   assign mem_write_b = cmem_write_b;
   assign mem_byte_enable_b = cmem_byte_enable_b;
   assign mem_address_b = cmem_address_b;
   assign mem_wdata_b = cmem_wdata_b;

   cpu cpu
     (
      .clk(clk),
	  .cmem_resp_a;
      .cmem_rdata_a;
      .cmem_read_a;
      .cmem_write_a;
      .cmem_byte_enable_a;
      .cmem_address_a;
      .cmem_wdata_a;

      .cmem_resp_b;
      .cmem_rdata_b;
      .cmem_read_b;
      .cmem_write_b;
      .cmem_byte_enable_b;
      .cmem_address_b;
      .cmem_wdata_b;


      );

//   cache cache
//     (
//      .clk(clk),
//      .cmem_resp(cmem_resp),
//      .cmem_rdata(cmem_rdata),
//      .cmem_read(cmem_read),
//      .cmem_write(cmem_write),
//      .cmem_byte_enable(cmem_byte_enable),
//      .cmem_address(cmem_address),
//      .cmem_wdata(cmem_wdata),
//
//      .pmem_resp(pmem_resp),
//      .pmem_address(pmem_address),
//      .pmem_wdata(pmem_wdata),
//      .pmem_rdata(pmem_rdata),
//      .pmem_read(pmem_read),
//      .pmem_write(pmem_write)
//      );


endmodule : mp3
