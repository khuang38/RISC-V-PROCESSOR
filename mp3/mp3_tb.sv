module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
/* Port A */
logic mem_resp_a;
logic mem_read_a;
logic mem_write_a;
logic [3:0] mem_byte_enable_a;
logic [31:0] mem_address_a;
logic [31:0] mem_rdata_a;
logic [31:0] mem_wdata_a;
//logic [31:0] write_data_a;
//logic [31:0] write_address_a;

/* Port B */
logic mem_resp_b;
logic mem_read_b;
logic mem_write_b;
logic [3:0] mem_byte_enable_b;
logic [31:0] mem_address_b;
logic [31:0] mem_rdata_b;
logic [31:0] mem_wdata_b;
//logic [31:0] write_data_b;
//logic [31:0] write_address_b;

//logic write;
logic [31:0] registers [32];

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

assign registers = dut.datapath.register_file.data;
assign halt = ((dut.datapath.instruct_register.data == 32'h00000063) | (dut.datapath.instruct_register.data == 32'h0000006F));

always @(posedge clk)
begin
//    if (mem_write & mem_resp) begin
//        write_address = mem_address;
//        write_data = mem_wdata;
//        write = 1;
//    end else begin
//        write_address = 32'hx;
//        write_data = 32'hx;
//        write = 0;
//    end
    if (halt) $finish;
end

mp3 dut
(
    .clk,
	/* Port A */
    .mem_resp_a,
    .mem_rdata_a,
    .mem_read_a,
    .mem_write_a,
    .mem_byte_enable_a,
    .mem_address_a,
    .mem_wdata_a,
	/* Port B */
	.mem_resp_b,
    .mem_rdata_b,
    .mem_read_b,
    .mem_write_b,
    .mem_byte_enable_b,
    .mem_address_b,
    .mem_wdata_b
);

magic_memory_dp memory
(
	.clk,

    /* Port A */
    .read_a(mem_read_a),
    .write_a(mem_write_a),
    .wmask_a(mem_byte_enable_a),
    .address_a(mem_address_a),
    .wdata_a(mem_wdata_a),
    .resp_a(mem_resp_a),
    .rdata_a(mem_rdata_a),

    /* Port B */
    .read_b(mem_read_b),
    .write_b(mem_write_b),
    .wmask_b(mem_byte_enable_b),
    .address_b(mem_address_b),
    .wdata_b(mem_wdata_b),
    .resp_b(mem_resp_b),
	.rdata_b(mem_rdata_b)
);

endmodule : mp3_tb
