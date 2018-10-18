module cache
(
    input         clk,

    output        cmem_resp,
    output [31:0] cmem_rdata,
    input         cmem_read,
    input         cmem_write,
    input [3:0]   cmem_byte_enable,
    input [31:0]  cmem_address,
    input [31:0]  cmem_wdata,

    input         pmem_resp,
    input [255:0]  pmem_rdata,
    output        pmem_read,
    output        pmem_write,
    output [31:0] pmem_address,
    output [255:0] pmem_wdata
);

   logic          load_lru, load_dirty0, load_dirty1, load_data0, load_data1;
   logic          load_tag0, load_tag1, load_valid0, load_valid1;
   logic          datain_sel;
   logic [1:0]    addr_sel;
   logic          hit0, hit1, dirty0, dirty1, lru_out;


   cache_datapath datapath
     (
      .clk(clk),
      .cmem_rdata(cmem_rdata),
      .cmem_wdata(cmem_wdata),
      .cmem_address(cmem_address),
      .cmem_byte_enable(cmem_byte_enable),
      .pmem_rdata(pmem_rdata),
      .pmem_wdata(pmem_wdata),
      .pmem_address(pmem_address),
      .pmem_read(pmem_read),

      .load_lru(load_lru),
      .load_dirty0(load_dirty0),
      .load_dirty1(load_dirty1),
      .load_tag0(load_tag0),
      .load_tag1(load_tag1),
      .load_valid0(load_valid0),
      .load_valid1(load_valid1),
      .load_data0(load_data0),
      .load_data1(load_data1),
      .hit0(hit0),
      .hit1(hit1),
      .dirty0(dirty0),
      .dirty1(dirty1),
      .datain_sel(datain_sel),
      .addr_sel(addr_sel),
      .lru_out(lru_out)
     );

   cache_control control
     (
      .clk(clk),
      .cmem_read(cmem_read),
      .cmem_write(cmem_write),
      .cmem_resp(cmem_resp),
      .pmem_read(pmem_read),
      .pmem_write(pmem_write),
      .pmem_resp(pmem_resp),

      .load_lru(load_lru),
      .load_dirty0(load_dirty0),
      .load_dirty1(load_dirty1),
      .load_tag0(load_tag0),
      .load_tag1(load_tag1),
      .load_valid0(load_valid0),
      .load_valid1(load_valid1),
      .load_data0(load_data0),
      .load_data1(load_data1),
      .hit0(hit0),
      .hit1(hit1),
      .dirty0(dirty0),
      .dirty1(dirty1),
      .datain_sel(datain_sel),
      .addr_sel(addr_sel),
      .lru_out(lru_out)
      );




endmodule : cache
