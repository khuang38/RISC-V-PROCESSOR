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
    output logic [31:0] cmem_wdata_b,

	input l1i_hit,
    input l1d_hit,
	input l2_hit,
	input l2_read_or_write
);
	always @(posedge clk) begin
		if(cmem_write_b && cmem_resp_b) begin
			$display("write_l1d %h %h %h", cmem_address_b, cmem_wdata_b, cmem_byte_enable_b);
		end
	end

	// pipe line control logic
	logic is_mispredict;
	logic IF_branch_prediction, ID_branch_prediction, EXE_branch_prediction, MEM_branch_prediction;
	logic [1:0] pc_mux_sel;
	logic is_if_branch;

    logic [31:0] MEM_data_b, MEM_ins, MEM_pc;
	 logic btb_resp;
    logic PPLINE_reset;
	 assign PPLINE_reset = is_mispredict;
	 
	 logic memory_is_busy;
	 assign memory_is_busy = (cmem_read_a & !cmem_resp_a) | ((cmem_write_b | cmem_read_b) & !cmem_resp_b) | (is_if_branch & ~btb_resp);

	 logic PPLINE_run;
    assign PPLINE_run = !memory_is_busy;


    logic [1:0] EXE_alu_fwd_mux_sel1, EXE_alu_fwd_mux_sel2;



    // Define all the control words
	logic insert_bubble;
    rv32i_control_word ID_cw, ID_cw_out, EXE_cw, MEM_cw, WB_cw;

    // stage IF;
    logic [31:0] IF_pc_in, IF_pc_out, IF_ins;
    logic [31:0] MEM_alu_out;
    logic [1:0] MEM_pc_sel;
    logic MEM_br_en;

    assign MEM_pc_sel = MEM_cw.pcmux_sel;
    assign IF_ins = cmem_rdata_a;
    assign cmem_read_a = 1'b1;
    assign cmem_write_a = 1'b0;    // TODO::modified signal width in the future
    assign cmem_byte_enable_a = 4'b1111;
    assign cmem_address_a = IF_pc_out;
    assign cmem_wdata_a = 32'h0;
		logic load_if_id;

		assign load_if_id = PPLINE_run & ((~insert_bubble) | PPLINE_reset);
	pc_register pc
	(
    	.clk(clk),
    	.load( load_if_id),
    	.in(IF_pc_in),
    	.out(IF_pc_out)
	);

	
	assign is_mispredict = (MEM_pc_sel == 2'h1 & MEM_br_en != MEM_branch_prediction) | (MEM_pc_sel == 2'h2);
	assign pc_mux_sel = is_mispredict ? ((MEM_br_en | MEM_pc_sel == 2'h2) ? 2'h1 : 2'h2): 2'h0;
	
	logic [31:0] IF_pc_prediction;
	logic [31:0] btb_output_pc;
	 
	mux2 #(.width(32)) pc_prediction_mux
    (
        .sel(is_if_branch & IF_branch_prediction),
        .a(IF_pc_out + 32'h4),
        .b(btb_output_pc),
        .f(IF_pc_prediction)
    );
	
    mux4 #(.width(32)) pc_mux
    (
        .sel(pc_mux_sel),
        .a(IF_pc_prediction),
        .b(MEM_alu_out),
        .c(MEM_pc + 32'h4),
		  .d(32'h0),
		  .f(IF_pc_in)
    );


    // Stage ID
	logic [31:0] ID_pc, ID_ins, WB_ins;
	logic [31:0] ID_data_a, ID_data_b;
	logic WB_load_regfile;
   logic [31:0] WB_reg_in;
	logic [31:0] MEM_reg_in;
	logic [4:0] ID_rs1, ID_rs2, WB_rd;
    assign ID_rs2 = ID_ins[24:20];
    assign ID_rs1 = ID_ins[19:15];
    assign WB_rd = WB_ins[11:7];

    control_rom controller
    (
        .instruction(ID_ins),
        .ctrl(ID_cw)
    );
	 
	
	 assign is_if_branch = IF_ins[6:0] ==7'b1100011;
	 btb btb_ins(
		.clk(clk),
		.input_pc(IF_pc_out),
		.input_ins(IF_ins),
		.read(is_if_branch && cmem_resp_a),
		.output_pc(btb_output_pc),
		.btb_resp(btb_resp)
	);

	stage_register #(.width(64 + 1)) IF_ID
	(
		.clk(clk),
		.load(load_if_id),
		.reset(PPLINE_reset),
		.in({IF_branch_prediction, IF_pc_out, IF_ins}),
		.out({ID_branch_prediction, ID_pc, ID_ins})
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
	logic [31:0] EXE_pc, EXE_ins, EXE_data_a, EXE_data_b, EXE_perf_out, MEM_perf_out, WB_perf_out;
	logic [31:0] EXE_alu_in1, EXE_alu_in2,EXE_alu_fwd_in1, EXE_alu_fwd_in2, EXE_alu_out;
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

	 mux2 #(.width($bits(rv32i_control_word))) insert_bubble_mux
    (
        .sel(insert_bubble),
        .a(ID_cw),
        .b(35'd0),
        .f(ID_cw_out)
    );

	stage_register #(.width(32 * 4 + $bits(rv32i_control_word) + 1)) ID_EXE
	(
		.clk(clk),
		.load(PPLINE_run),
		.reset(PPLINE_reset),
		.in({ID_branch_prediction, ID_cw_out, ID_pc, ID_ins, ID_data_a, ID_data_b}),
		.out({EXE_branch_prediction, EXE_cw, EXE_pc, EXE_ins, EXE_data_a, EXE_data_b})
	);

	mux4 #(.width(32)) EXE_alu_mux1
    (
        .sel(EXE_alu_sel1),
        .a(EXE_alu_fwd_in1),
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
        .i5(EXE_alu_fwd_in2),
        .i6(32'h0),
        .i7(32'h0),
	    .f(EXE_alu_in2)
    );


	mux4 #(.width(32)) EXE_alu_fwd_mux1
    (
        .sel(EXE_alu_fwd_mux_sel1),
        .a(EXE_data_a),
        .b(MEM_reg_in),
    	.c(WB_reg_in),
    	.d(32'h0),
        .f(EXE_alu_fwd_in1)
    );

	mux4 #(.width(32)) EXE_alu_fwd_mux2
    (
        .sel(EXE_alu_fwd_mux_sel2),
        .a(EXE_data_b),
        .b(MEM_reg_in),
    	.c(WB_reg_in),
    	.d(32'h0),
        .f(EXE_alu_fwd_in2)
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
        .a(EXE_alu_fwd_in2),
        .b(EXE_i_imm),
        .f(EXE_cmp_mux_out)
    );

    cmp cmp
    (
        .cmpop(EXE_cmpop),
        .a(EXE_alu_fwd_in1),
        .b(EXE_cmp_mux_out),
        .f(EXE_br_en)
    );

    // Stage MEM

    stage_register #(.width(32*5 + 1 + 1 + $bits(rv32i_control_word))) EXE_MEM
    (
        .clk(clk),
        .load(PPLINE_run),
		  .reset(PPLINE_reset),
        .in({EXE_branch_prediction, EXE_cw, EXE_pc, EXE_perf_out, EXE_alu_out, EXE_alu_fwd_in2, EXE_ins, EXE_br_en}),
        .out({MEM_branch_prediction, MEM_cw, MEM_pc, MEM_perf_out, MEM_alu_out, MEM_data_b, MEM_ins, MEM_br_en})
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
    logic [2:0] WB_reg_sel;
	logic [2:0] WB_mdr_sel;
    logic WB_br_en;

	assign WB_mdr_sel = WB_cw.mdr_sel;
    assign WB_reg_sel = WB_cw.regfilemux_sel;
    assign WB_load_regfile = WB_cw.load_regfile;

    stage_register #(.width(32*5 + 1 + $bits(rv32i_control_word))) MEM_WB
    (
        .clk(clk),
        .load(PPLINE_run),
		  .reset(1'b0),
        .in({MEM_cw, MEM_pc, MEM_perf_out, MEM_alu_out, MEM_rdata, MEM_ins, MEM_br_en}),
        .out({WB_cw, WB_pc, WB_perf_out, WB_alu_out, WB_rdata, WB_ins, WB_br_en})
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


    mux8 wb_mux
    (
        .sel(WB_reg_sel),
        .i0(WB_mdr_mux_out),
        .i1({31'h0, WB_br_en}),
        .i2(WB_alu_out),
        .i3(WB_pc_plus_4),
		.i4(WB_perf_out),
		.i5(32'h0),
		.i6(32'h0),
		.i7(32'h0),
        .f(WB_reg_in)
    );

	logic [31:0] MEM_pc_plus_4;
	logic [2:0] MEM_reg_sel;
	assign MEM_reg_sel = MEM_cw.regfilemux_sel;
	assign MEM_pc_plus_4 = MEM_pc + 32'h4;

	mux8 mem_mux
    (
        .sel(MEM_reg_sel),
        .i0(32'h0),
        .i1({31'h0, MEM_br_en}),
        .i2(MEM_alu_out),
        .i3(MEM_pc_plus_4),
		.i4(MEM_perf_out),
		.i5(32'h0),
		.i6(32'h0),
		.i7(32'h0),
        .f(MEM_reg_in)
    );

	logic MEM_load_regfile, EXE_mem_read;
	logic [4:0] EXE_rs1, EXE_rs2, MEM_rd, EXE_rd;

	assign EXE_mem_read = EXE_cw.mem_read;
	assign EXE_rs2 = EXE_ins[24:20];
    assign EXE_rs1 = EXE_ins[19:15];
	assign MEM_rd = MEM_ins[11:7];
	assign MEM_load_regfile = MEM_cw.load_regfile;
	assign EXE_rd = EXE_ins[11:7];


	data_forward_unit dfu(
		.mem_load_regfile(MEM_load_regfile),
		.mem_rd(MEM_rd),
		.wb_load_regfile(WB_load_regfile),
		.wb_rd(WB_rd),
		.exe_rs1(EXE_rs1),
		.exe_rs2(EXE_rs2),
		.alufwdmux1_sel(EXE_alu_fwd_mux_sel1),
		.alufwdmux2_sel(EXE_alu_fwd_mux_sel2)
	);

	hazard_detect_unit hdu(
		.exe_mem_read(EXE_mem_read),
		.exe_rd(EXE_rd),
		.id_rs1(ID_rs1),
		.id_rs2(ID_rs2),
		.insert_bubble(insert_bubble)
	);

    perf_counter perf_cnter(
	    .clk(clk),
		 .clear(EXE_cw.regfilemux_sel == 3'h4),
       .read_src(EXE_rs1),
	    .read_data(EXE_perf_out),
	    .l1i_hit(l1i_hit),
	    .l1d_hit(l1d_hit),
	    .l2_hit(l2_hit),
	    .l1i_read_or_write(cmem_read_a | cmem_write_a),
	    .l1d_read_or_write(cmem_read_b | cmem_write_b),
	    .l2_read_or_write(l2_read_or_write),
	    .is_branch(MEM_cw.is_branch),
	    .is_mispredict(is_mispredict),
	    .is_stall( (~PPLINE_run) | insert_bubble)
	);
	
	tournament_predictor tp(
	.clk(clk),
	.read_pc(IF_pc_out),
	.prediction(IF_branch_prediction),
	.write_pc(MEM_pc),
	.write(MEM_cw.is_branch),
	.write_value(MEM_br_en)
);


endmodule : cpu
