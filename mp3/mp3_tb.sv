module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp;
logic [255:0] pmem_rdata;
logic pmem_read;
logic pmem_write;
logic [31:0] pmem_address;
logic [255:0] pmem_wdata;
logic halt;
//logic write;
//logic [31:0] registers [32];

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

//assign registers = dut.datapath.register_file.data;
//

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
