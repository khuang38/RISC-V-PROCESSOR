module cache_datapath
(
    input                clk,


    output logic [31:0]  cmem_rdata,
    input [3:0]          cmem_byte_enable,
    input [31:0]         cmem_address,
    input [31:0]         cmem_wdata,

    output logic [255:0] pmem_wdata,
    input [255:0]        pmem_rdata,
    output logic [31:0]  pmem_address,

    input                load_valid0,
    input                load_valid1,
    input                load_dirty0,
    input                load_dirty1,
    input                load_tag0,
    input                load_tag1,
    input                load_data0,
    input                load_data1,
    input                load_lru,

    input                pmem_read,
    input [1:0]          addr_sel,
    input                datain_sel,

    output logic         hit0,
    output logic         hit1,
    output logic         dirty0,
    output logic         dirty1,
    output logic         lru_out

);

   logic [23:0]    tag, tag0_out, tag1_out, tag_out;
   logic [2:0]     index;
   logic [4:0]     offset;
   logic           valid0_out;
   logic           valid1_out;
   logic           eq0;
   logic           eq1;
   logic [255:0]   word_sel_out, data_in, data0_out, data1_out, set_out;
   logic [31:0]    word_out;

   assign tag = cmem_address[31:8];
   assign index = cmem_address[7:5];
   assign offset = cmem_address[4:0];
   assign eq0 = (tag0_out == tag);
   assign eq1 = (tag1_out == tag);
   assign hit0 = valid0_out & eq0;
   assign hit1 = valid1_out & eq1;
   assign pmem_address = {tag_out, index, 5'b0};

   word_sel word_sel_ins
     (
	   .offset(offset),
      .cmem_byte_enable(cmem_byte_enable),
      .cmem_wdata(cmem_wdata),
      .set_out(set_out),
      .word_sel_out(word_sel_out)
      );

   mux2 #(.width(256)) datain_mux
     (
      .sel(datain_sel),
      .a(pmem_rdata),
      .b(word_sel_out),
      .f(data_in)
      );

   mux4 #(.width(24)) addr_mux
     (
      .sel(addr_sel),
      .a(tag),
      .b(tag0_out),
      .c(tag1_out),
      .d(24'b0),
      .f(tag_out)
      );

   mux2 #(.width(256)) set_mux
     (
      .sel(hit1),
      .a(data0_out),
      .b(data1_out),
      .f(set_out)
      );
		
	mux2 #(.width(256)) pmem_wdata_mux
     (
      .sel(lru_out),
      .a(data0_out),
      .b(data1_out),
      .f(pmem_wdata)
      );
		
   mux8 #(.width(32)) word_mux
     (
      .sel(offset[4:2]),
      .i0(set_out[31:0]),
      .i1(set_out[63:32]),
      .i2(set_out[95:64]),
      .i3(set_out[127:96]),
      .i4(set_out[159:128]),
      .i5(set_out[191:160]),
      .i6(set_out[223:192]),
      .i7(set_out[255:224]),
      .f(word_out)
      );

   mux4 #(.width(32)) word_out_mux
     (
     .sel(offset[1:0]),
     .a(word_out),
     .b({8'b0,word_out[31:8]}),
     .c({16'b0,word_out[31:16]}),
     .d({24'b0,word_out[31:24]}),
     .f(cmem_rdata)
   );


   array #(.width(1)) valid0
     (
      .clk(clk),
      .write(load_valid0),
      .index(index),
      .datain(1'b1),
      .dataout(valid0_out)
      );

  array #(.width(1)) valid1
     (
      .clk(clk),
      .write(load_valid1),
      .index(index),
      .datain(1'b1),
      .dataout(valid1_out)
      );

   array #(.width(1)) dirty0_arr
     (
      .clk(clk),
      .write(load_dirty0),
      .index(index),
      .datain(~pmem_read),
      .dataout(dirty0)
      );

  array #(.width(1)) dirty1_arr
     (
      .clk(clk),
      .write(load_dirty1),
      .index(index),
      .datain(~pmem_read),
      .dataout(dirty1)
      );

   array #(.width(24)) tag_array0
     (
      .clk(clk),
      .write(load_tag0),
      .index(index),
      .datain(tag),
      .dataout(tag0_out)
      );

   array #(.width(24)) tag_array1
     (
      .clk(clk),
      .write(load_tag1),
      .index(index),
      .datain(tag),
      .dataout(tag1_out)
      );

   array #(.width(256)) data_array0
     (
      .clk(clk),
      .write(load_data0),
      .index(index),
      .datain(data_in),
      .dataout(data0_out)
      );

   array #(.width(256)) data_array1
     (
      .clk(clk),
      .write(load_data1),
      .index(index),
      .datain(data_in),
      .dataout(data1_out)
      );

   array #(.width(1)) lru_bit
     (
      .clk(clk),
      .write(load_lru),
      .index(index),
      .datain(hit0),
      .dataout(lru_out)
      );


endmodule : cache_datapath
