module cpu
(
    input clk,
    // Used for Instruction
    input cmem_resp_a,
    input [31:0] cmem_rdata_a,
    output logic cmem_read_a,
    output logic cmem_write_a,
    output logic [3:0] cmem_byte_enable_a,
    output logic [31:0] cmem_address_a,
    output logic [31:0] cmem_wdata_a,
    // Used for Data
    input cmem_resp_b,
    input [31:0] cmem_rdata_b,
    output logic cmem_read_b,
    output logic cmem_write_b,
    output logic [3:0] cmem_byte_enable_b,
    output logic [31:0] cmem_address_b,
    output logic [31:0] cmem_wdata_b
);


    // stage IF;
    logic [31:0] IF_pc_in, IF_pc_out, IF_ins;
    logic [31:0] MEM_alu_out;
    logic MEM_pc_sel;

    assign IF_ins = cmem_rdata_a;
    assign cmem_read_a = 1'b1;
    assign cmem_write_a = 1'b0;
    assign cmem_byte_enable_a = 4'b1111;
    assign cmem_address_a = IF_pc_out;
    assign cmem_wdata_a = 32'h0;

	pc_register pc
	(
    	.clk(clk),
    	.load(1'b1),
    	.in(IF_pc_in),
    	.out(IF_pc_out)
	);

    mux2 #(.width(32)) pc_mux
    (
      .sel(MEM_pc_sel & MEM_br_en),
      .a(IF_pc_out + 32'h4),
      .b(MEM_alu_out),
      .f(IF_pc_in)
    );


    // stage ID
	logic [31:0] ID_pc, ID_ins;
	logic [31:0] ID_data_a, ID_data_b;
	logic WB_load_regfile;
    logic [31:0] WB_reg_in;

    assign ID_rs2 = ID_ins[24:20];
    assign ID_rs1 = ID_ins[19:15];

	register #(.width(64)) IF_ID
	(
		.clk(clk),
		.load(1'b1),
		.in({IF_pc, IF_ins}),
		.out({ID_pc, ID_ins})
	);

	regfile ID_reg_file
	(
		.clk(clk),
		.load(WB_load_regfile),
		.in(WB_reg_in),
		.src_a(ID_rs1),
		.src_b(ID_rs2),
		.dest(WB_rd),
		.reg_a(ID_data_a),
		.reg_b(ID_data_b)
	);

    // stage EXE
	logic [31:0] EXE_pc, EXE_ins, EXE_data_a, EXE_data_b;
	logic [31:0] EXE_alu_in1, EXE_alu_in2, EXE_alu_out;
    logic [1:0] EXE_alu_sel1;
    logic [2:0] EXE_alu_sel2;
    logic [31:0] EXE_i_imm, EXE_s_imm, EXE_b_imm, EXE_u_imm, EXE_j_imm;
    alu_ops EXE_aluop;
    logic EXE_cmp_sel, EXE_br_en;
    logic [31:0] EXE_cmp_mux_out;

    assign EXE_i_imm = {{21{EXE_ins[31]}}, EXE_ins[30:20]};
    assign EXE_s_imm = {{21{EXE_ins[31]}}, EXE_ins[30:25], EXE_ins[11:7]};
    assign EXE_b_imm = {{20{EXE_ins[31]}}, EXE_ins[7], EXE_ins[30:25], EXE_ins[11:8], 1'b0};
    assign EXE_u_imm = {EXE_ins[31:12], 12'h000};
    assign EXE_j_imm = {{12{EXE_ins[31]}}, EXE_ins[19:12], EXE_ins[20], EXE_ins[30:21], 1'b0};

    // TODO::modified signal width in the future
	register #(.width(64)) ID_EXE
	(
		.clk(clk),
		.load(1'b1),
		.in({ID_cw,  ID_pc,  ID_ins,  ID_data_a,  ID_data_b}),
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
      .sel(EXE_alu_sel2),
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

    mux2 cmp_mux
    (
        .sel(EXE_cmp_sel),
        .a(EXE_data_b),
        .b(EXE_i_imm),
        .f(EXE_cmp_mux_out)
        );

    cmp cmp
    (
        .cmpop(EXE_cmpop),
        .a(EXE_data_a),
        .b(EXE_cmp_mux_out)
        .f(EXE_br_en)
        );

    // stage MEM
    // TODO:: MEM_cw
    logic [31:0] MEM_alu_out, MEM_data_b;
    logic MEM_br_en;
    register #(.width(64)) EXE_MEM
    (
        .clk(clk),
        .load(1'b1),
        .in({EXE_cw, EXE_alu_out, EXE_data_b, EXE_br_en}),
        .out({MEM_cw, MEM_alu_out, MEM_data_b, MEM_br_en})
    );

    logic [31:0] MEM_rdata;
    logic MEM_read, MEM_write;

    assign MEM_rdata = cmem_rdata_b;
    assign cmem_read_b = MEM_read;
    assign cmem_write_b = MEM_write;
    assign cmem_byte_enable_b = 4'b1111;
    assign cmem_address_b = MEM_alu_out;
    assign cmem_wdata_b = MEM_data_b;

    // stage WB
    // TODO:: WB_cw,
    logic [31:0] WB_alu_out, WB_rdata;
    logic [1:0] WB_reg_sel;
    logic WB_br_en;

    register #(.width(64)) MEM_WB
    (
        .clk(clk),
        .load(1'b1),
        .in({MEM_cw, MEM_alu_out, MEM_rdata, MEM_br_en}),
        .out({WB_cw, WB_alu_out, WB_rdata, WB_br_en})
    );

    mux4 wb_mux
    (
        .sel(WB_reg_sel),
        .a(WB_rdata),
        .b({31'h0, WB_br_en}),
        .c(WB_alu_out),
        .d(32'h0),
        .f(WB_reg_in)
        );

);


endmodule : cache_datapath
