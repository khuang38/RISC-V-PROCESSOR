module memory_latch(
	input clk,
	 output         cmem_resp,
    output [255:0]  cmem_rdata,
    input          cmem_read,
    input          cmem_write,
    input [31:0]  cmem_address,
    input [255:0]  cmem_wdata,

    input          pmem_resp,
    input [255:0]  pmem_rdata,
    output         pmem_read,
    output         pmem_write,
    output [31:0]  pmem_address,
    output [255:0] pmem_wdata
);

reg read, write;
reg [31:0] addr;
reg [255:0] wdata;

initial begin
read = 0;
write = 0;
addr = 0;
wdata = 0;
end

assign cmem_resp = (addr == cmem_address) ? pmem_resp : 0;
assign cmem_rdata = pmem_rdata;

assign pmem_address = addr;
assign pmem_wdata = wdata;
assign pmem_write = write;
assign pmem_read = read;

always_ff @(posedge clk) begin
	read <= cmem_read;
	write <= cmem_write;
	addr <= cmem_address;
	wdata <= cmem_wdata;
end

endmodule: memory_latch