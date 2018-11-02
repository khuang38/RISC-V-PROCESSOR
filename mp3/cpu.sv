import rv32i_types::*;

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
	// pipe line control logic
	
	logic pc_mux_sel;
	
	logic PPLINE_run;
   assign PPLINE_run = !((cmem_read_a & !cmem_resp_a) | ((cmem_write_b | cmem_read_b) & !cmem_resp_b));
	logic PPLINE_reset = pc_mux_sel;


    // Define all the control words
    rv32i_control_word ID_cw, EXE_cw, MEM_cw, WB_cw;

    // stage IF;
    logic [31:0] IF_pc_in, IF_pc_out, IF_ins;
    logic [31:0] MEM_alu_out;
    logic MEM_pc_sel;
    logic MEM_br_en;

    assign MEM_pc_sel = MEM_cw.pcmux_sel;
    assign IF_ins = cmem_rdata_a;
    assign cmem_read_a = 1'b1;
    assign cmem_write_a = 1'b0;    // TODO::modified signal width in the future
    assign cmem_byte_enable_a = 4'b1111;
    assign cmem_address_a = IF_pc_out;
    assign cmem_wdata_a = 32'h0;

	pc_register pc
	(
    	.clk(clk),
    	.load(PPLINE_run),
    	.in(IF_pc_in),
    	.out(IF_pc_out)
	);
	
	assign pc_mux_sel = (MEM_pc_sel == 2'h1 & MEM_br_en) | (MEM_br_en == 2'h2);

    mux2 #(.width(32)) pc_mux
    (
        .sel(pc_mux_sel),
        .a(IF_pc_out + 32'h4),
        .b(MEM_alu_out),
        .f(IF_pc_in)
    );


    // Stage ID
	 logic [31:0] ID_pc, ID_ins, WB_ins;
	 logic [31:0] ID_data_a, ID_data_b;
	 logic WB_load_regfile;
    logic [31:0] WB_reg_in;
	 logic [4:0] ID_rs1, ID_rs2, WB_rd;

    assign ID_rs2 = ID_ins[24:20];
    assign ID_rs1 = ID_ins[19:15];
    assign WB_rd = WB_ins[11:7];

    control_rom controller
    (
        .instruction(ID_ins),
        .ctrl(ID_cw)
    );

	stage_register #(.width(64)) IF_ID
	(
		.clk(clk),
		.load(PPLINE_run),
		.reset(PPLINE_reset),
		.in({IF_pc_out, IF_ins}),
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

    // Stage EXE
	logic [31:0] EXE_pc, EXE_ins, EXE_data_a, EXE_data_b;
	logic [31:0] EXE_alu_in1, EXE_alu_in2, EXE_alu_out;
    logic [1:0] EXE_alu_sel1;
    logic [2:0] EXE_alu_sel2;
    logic [31:0] EXE_i_imm, EXE_s_imm, EXE_b_imm, EXE_u_imm, EXE_j_imm;
    alu_ops EXE_aluop;
    branch_funct3_t EXE_cmpop;
    logic EXE_cmp_sel, EXE_br_en;
    logic [31:0] EXE_cmp_mux_out;

    assign EXE_alu_sel1 = EXE_cw.alumux1_sel;
    assign EXE_alu_sel2 = EXE_cw.alumux2_sel;
    assign EXE_aluop = EXE_cw.aluop;
    assign EXE_cmpop = EXE_cw.cmp_op;
    assign EXE_cmp_sel = EXE_cw.cmpmux_sel;
    assign EXE_i_imm = {{21{EXE_ins[31]}}, EXE_ins[30:20]};
    assign EXE_s_imm = {{21{EXE_ins[31]}}, EXE_ins[30:25], EXE_ins[11:7]};
    assign EXE_b_imm = {{20{EXE_ins[31]}}, EXE_ins[7], EXE_ins[30:25], EXE_ins[11:8], 1'b0};
    assign EXE_u_imm = {EXE_ins[31:12], 12'h000};
    assign EXE_j_imm = {{12{EXE_ins[31]}}, EXE_ins[19:12], EXE_ins[20], EXE_ins[30:21], 1'b0};

	stage_register #(.width(32 * 4 + $bits(rv32i_control_word))) ID_EXE
	(
		.clk(clk),
		.load(PPLINE_run),
		.reset(PPLINE_reset),
		.in({ID_cw, ID_pc, ID_ins, ID_data_a, ID_data_b}),
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
	     .i4(EXE_j_imm),
        .i5(EXE_data_b),
        .i6(32'h0),
        .i7(32'h0),
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
        .b(EXE_cmp_mux_out),
        .f(EXE_br_en)
    );

    // Stage MEM
    logic [31:0] MEM_data_b, MEM_ins, MEM_pc;

    stage_register #(.width(32*4 + 1 + $bits(rv32i_control_word))) EXE_MEM
    (
        .clk(clk),
        .load(PPLINE_run),
		  .reset(PPLINE_reset),
        .in({EXE_cw, EXE_pc, EXE_alu_out, EXE_data_b, EXE_ins, EXE_br_en}),
        .out({MEM_cw, MEM_pc, EM_alu_out, MEM_data_b, MEM_ins, MEM_br_en})
    );

    logic [31:0] MEM_rdata;
    logic MEM_read, MEM_write;

    assign MEM_read = MEM_cw.mem_read;
    assign MEM_write = MEM_cw.mem_write;
    assign MEM_rdata = cmem_rdata_b;
    assign cmem_read_b = MEM_read;
    assign cmem_write_b = MEM_write;
    assign cmem_byte_enable_b = MEM_cw.mem_byte_enable;
    assign cmem_address_b = MEM_alu_out;
    assign cmem_wdata_b = MEM_data_b;

    // Stage WB
    logic [31:0] WB_alu_out, WB_rdata, WB_pc, WB_pc_plus_4, WB_mdr_mux_out;
    logic [1:0] WB_reg_sel;
	 logic [2:0] WB_mdr_sel;
    logic WB_br_en;

	 assign WB_mdr_sel = WB_cw.mdr_sel;
    assign WB_reg_sel = WB_cw.regfilemux_sel;
    assign WB_load_regfile = WB_cw.load_regfile;

    stage_register #(.width(32*4 + 1 + $bits(rv32i_control_word))) MEM_WB
    (
        .clk(clk),
        .load(PPLINE_run),
		  .reset(PPLINE_reset),
        .in({MEM_cw, MEM_pc, MEM_alu_out, MEM_rdata, MEM_ins, MEM_br_en}),
        .out({WB_cw, WB_pc, WB_alu_out, WB_rdata, WB_ins, WB_br_en})
    );
	 
	 assign WB_pc_plus_4 = WB_pc + 32'h4;

	 mux8 mdr_mux
	 (
		 .sel(WB_mdr_sel),
		 .i0(WB_rdata),
       .i1({{16{WB_rdata[15]}}, WB_rdata[15:0]}),
       .i2({16'b0, WB_rdata[15:0]}),
       .i3({{24{WB_rdata[7]}}, WB_rdata[7:0]}),
       .i4({24'b0, WB_rdata[7:0]}),
       .i5(32'h0),
       .i6(32'h0),
       .i7(32'h0),
	    .f(WB_mdr_mux_out)
	 );
	 
    mux4 wb_mux
    (
        .sel(WB_reg_sel),
        .a(WB_mdr_mux_out),
        .b({31'h0, WB_br_en}),
        .c(WB_alu_out),
        .d(WB_pc_plus_4),
        .f(WB_reg_in)
    );


endmodule : cpu
