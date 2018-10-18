
module mp3
(
    input         clk,
    input         pmem_resp,
    input logic [255:0]  pmem_rdata,
    output        pmem_read,
    output        pmem_write,
    output logic [31:0] pmem_address,
    output logic [255:0] pmem_wdata
);

   /* from IR/cmp to controller*/

   logic          cmem_resp;
   logic [31:0]   cmem_rdata;
   logic          cmem_read;
   logic          cmem_write;
   logic [3:0]    cmem_byte_enable;
   logic [31:0]   cmem_address;
   logic [31:0]   cmem_wdata;

   cpu cpu
     (
      .clk(clk),
      .mem_resp(cmem_resp),
      .mem_rdata(cmem_rdata),
      .mem_read(cmem_read),
      .mem_write(cmem_write),
      .mem_byte_enable(cmem_byte_enable),
      .mem_address(cmem_address),
      .mem_wdata(cmem_wdata)
      );
   
   cache cache
     (
      .clk(clk),
      .cmem_resp(cmem_resp),
      .cmem_rdata(cmem_rdata),
      .cmem_read(cmem_read),
      .cmem_write(cmem_write),
      .cmem_byte_enable(cmem_byte_enable),
      .cmem_address(cmem_address),
      .cmem_wdata(cmem_wdata),
      
      .pmem_resp(pmem_resp),
      .pmem_address(pmem_address),
      .pmem_wdata(pmem_wdata),
      .pmem_rdata(pmem_rdata),
      .pmem_read(pmem_read),
      .pmem_write(pmem_write)
      );
   

endmodule : mp3
