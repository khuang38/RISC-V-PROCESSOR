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

// stage IF;
	wire [31:0] IF_pc_in, IF_pc_out;
	wire [31:0] WB_alu_out;
	wire IF_pc_sel;
	pc_register pc
	(
		.clk(clk),
		.load(1'b1),
		.in(IF_pc_in),
		.out(IF_pc_out)
	);
	
   mux2 #(.width(32)) addr_mux
     (
      .sel(IF_pc_sel),
      .a(IF_pc_out + 32'h4),
      .b(WB_alu_out),
      .f(IF_pc_in)
      );

// stage ID

	wire [31:0] ID_pc, ID_ins;
	wire [31:0] ID_data_a, ID_data_b;
	wire WB_load_regfile;
	
	register #(.width(64)) IF_ID
	(
		.clk(clk),
		.load(1'b1),
		.in( {IF_pc, IF_ins}),
		.out({ID_pc, ID_ins})
	);
	
	regfile ID_reg_file
	(
		.clk(clk),
		.load(WB_load_regfile),
		.in(),
		.src_a(ID_rs1),
		.src_b(ID_rs2),
		.dest(WB_rd),
		.reg_a(ID_data_a),
		.reg_b(ID_data_b)
	);
	
// stage EXE
	wire [31:0] EXE_pc, EXE_ins, EXE_data_a, EXE_data_b;
	wire [31:0] EXE_alu_in1, EXE_alu_in2, EXE_alu_out;

	register #(.width(64)) ID_EXE
	(
		.clk(clk),
		.load(1'b1),
		.in( {ID_cw,  ID_pc,  ID_ins,  ID_data_a,  ID_data_b}),
		.out({EXE_cw, EXE_pc, EXE_ins, EXE_data_a, EXE_data_b})
	);
	
	 mux4 #(.width(32)) EXE_alu_mux1
     (
      .sel(EXE_alu_sel1),
      .a(EXE_data_a),
      .b(EXE_pc),
		.c(32'h0),
		.d(32'h0),
      .f(EXE_alu_in1)
      );
	
	mux8 #(.width(32)) EXE_alu_mux2
     (
      .sel(EXE_alu_sel1),
      .i0(EXE_i_imm),
      .i1(EXE_u_imm),
      .i2(EXE_b_imm),
		.i3(EXE_s_imm),
		.i4(EXE_data_b),
		.f(EXE_alu_in2)
      );
	
	
	alu EXE_alu
	(
		.aluop(EXE_aluop),
		.a(EXE_alu_in1),
		.b(EXE_alu_in2),
		.f(EXE_alu_out)
	);
	
);

  
endmodule : cache_datapath
