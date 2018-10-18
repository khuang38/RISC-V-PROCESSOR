import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module cmp(
           input        branch_funct3_t cmpop,
           input        rv32i_word a,
           input        rv32i_word b,
           output logic f
);


   
always_comb
  begin
     f = 0;
     case(cmpop)
       beq: f = (a == b);
       bne: f = (a != b);
       blt: f = ($signed(a) < $signed(b));
       bge: f = ($signed(a) >= $signed(b));
       bltu: f = (a < b);
       bgeu: f = (a >= b);
     endcase // case (cmpop)
  end

endmodule: cmp
