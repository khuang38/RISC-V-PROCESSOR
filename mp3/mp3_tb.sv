module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
 input          pmem_resp;
 input [255:0]  pmem_rdata;
 output         pmem_read;
 output         pmem_write;
 output [31:0]  pmem_address;
 output [255:0] pmem_wdata;
logic halt;
//logic write;
//logic [31:0] registers [32];

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

//assign registers = dut.datapath.register_file.data;
//assign halt = ((dut.datapath.instruct_register.data == 32'h00000063) | (dut.datapath.instruct_register.data == 32'h0000006F));
//
//always @(posedge clk)
//begin
////    if (mem_write & mem_resp) begin
////        write_address = mem_address;
////        write_data = mem_wdata;
////        write = 1;
////    end else begin
////        write_address = 32'hx;
////        write_data = 32'hx;
////        write = 0;
////    end
//    if (halt) $finish;
//end

mp3 dut
(
    .clk,
	 .pmem_resp,
    .pmem_address,
    .pmem_wdata,
    .pmem_rdata,
    .pmem_read,
    .pmem_write
);

physical_memory memory
(
	.clk(clk),
   .read(pmem_read),
   .write(pmem_write),
   .address(pmem_address),
   .wdata(pmem_wdata),
   .resp(pmem_resp),
   .rdata(pmem_rdata)
);

endmodule : mp3_tb
