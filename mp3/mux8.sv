module mux8 #(parameter width = 32)
(
	input [2:0] sel,
	input [width - 1: 0] i0,i1,i2,i3,i4,i5,i6,i7,
	output logic [width-1: 0] f
);

always_comb
  begin
     if( sel == 0) f = i0;
     else if(sel == 1) f = i1;
     else if(sel == 2) f = i2;
     else if(sel == 3) f = i3;
     else if(sel == 4) f = i4;
     else if(sel == 5) f = i5;
     else if(sel == 6) f = i6;
     else f = i7;
  end

endmodule: mux8
