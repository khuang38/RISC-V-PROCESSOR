module word_sel
(
 input [4:0]			 offset,
 input [3:0]          cmem_byte_enable,
 input [31:0]         cmem_wdata,
 input [255:0]        set_out,
 output logic [255:0] word_sel_out
);
  always_comb
    begin
       word_sel_out = set_out;
       if(offset == 0) begin
          if(cmem_byte_enable[0]) word_sel_out[7:0] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[15:8] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[23:16] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[31:24] = cmem_wdata[31:24];
       end
       else if(offset == 1) begin
          if(cmem_byte_enable[0]) word_sel_out[15:8] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[23:16] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[31:24] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[39:32] = cmem_wdata[31:24];
       end
       else if(offset == 2) begin
          if(cmem_byte_enable[0]) word_sel_out[23:16] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[31:24] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[39:32] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[47:40] = cmem_wdata[31:24];
       end
       else if(offset == 3) begin
          if(cmem_byte_enable[0]) word_sel_out[31:24] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[39:32] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[47:40] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[55:48] = cmem_wdata[31:24];
       end
       else if(offset == 4) begin
          if(cmem_byte_enable[0]) word_sel_out[39:32] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[47:40] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[55:48] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[63:56] = cmem_wdata[31:24];
       end
       else if(offset == 5) begin
          if(cmem_byte_enable[0]) word_sel_out[47:40] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[55:48] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[63:56] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[71:64] = cmem_wdata[31:24];
       end
       else if(offset == 6) begin
          if(cmem_byte_enable[0]) word_sel_out[55:48] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[63:56] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[71:64] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[79:72] = cmem_wdata[31:24];
       end
       else if(offset == 7) begin
          if(cmem_byte_enable[0]) word_sel_out[63:56] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[71:64] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[79:72] = cmem_wdata[23:16];
            if(cmem_byte_enable[3]) word_sel_out[87:80] = cmem_wdata[31:24];
       end
       else if(offset == 8) begin
          if(cmem_byte_enable[0]) word_sel_out[71:64] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[79:72] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[87:80] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[95:88] = cmem_wdata[31:24];
       end
       else if(offset == 9) begin
          if(cmem_byte_enable[0]) word_sel_out[79:72] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[87:80] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[95:88] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[103:96] = cmem_wdata[31:24];
       end
       else if(offset == 10) begin
          if(cmem_byte_enable[0]) word_sel_out[87:80] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[95:88] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[103:96] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[111:104] = cmem_wdata[31:24];
       end
       else if(offset == 11) begin
          if(cmem_byte_enable[0]) word_sel_out[95:88] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[103:96] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[111:104] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[119:112] = cmem_wdata[31:24];
       end
       else if(offset == 12) begin
          if(cmem_byte_enable[0]) word_sel_out[103:96] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[111:104] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[119:112] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[127:120] = cmem_wdata[31:24];
       end
       else if(offset == 13) begin
          if(cmem_byte_enable[0]) word_sel_out[111:104] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[119:112] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[127:120] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[135:128] = cmem_wdata[31:24];
       end
       else if(offset == 14) begin
          if(cmem_byte_enable[0]) word_sel_out[119:112] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[127:120] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[135:128] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[143:136] = cmem_wdata[31:24];
       end
       else if(offset == 15) begin
          if(cmem_byte_enable[0]) word_sel_out[127:120] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[135:128] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[143:136] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[151:144] = cmem_wdata[31:24];
       end
       else if(offset == 16) begin
          if(cmem_byte_enable[0]) word_sel_out[135:128] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[143:136] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[151:144] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[159:152] = cmem_wdata[31:24];
       end
       else if(offset == 17) begin
          if(cmem_byte_enable[0]) word_sel_out[143:136] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[151:144] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[159:152] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[167:160] = cmem_wdata[31:24];
       end
       else if(offset == 18) begin
          if(cmem_byte_enable[0]) word_sel_out[151:144] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[159:152] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[167:160] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[175:168] = cmem_wdata[31:24];
       end
       else if(offset == 19) begin
          if(cmem_byte_enable[0]) word_sel_out[159:152] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[167:160] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[175:168] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[183:176] = cmem_wdata[31:24];
       end
       else if(offset == 20) begin
          if(cmem_byte_enable[0]) word_sel_out[167:160] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[175:168] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[183:176] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[191:184] = cmem_wdata[31:24];
       end
       else if(offset == 21) begin
          if(cmem_byte_enable[0]) word_sel_out[175:168] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[183:176] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[191:184] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[199:192] = cmem_wdata[31:24];
       end
       else if(offset == 22) begin
          if(cmem_byte_enable[0]) word_sel_out[183:176] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[191:184] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[199:192] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[207:200] = cmem_wdata[31:24];
       end
       else if(offset == 23) begin
          if(cmem_byte_enable[0]) word_sel_out[191:184] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[199:192] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[207:200] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[215:208] = cmem_wdata[31:24];
       end
       else if(offset == 24) begin
          if(cmem_byte_enable[0]) word_sel_out[199:192] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[207:200] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[215:208] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[223:216] = cmem_wdata[31:24];
       end
       else if(offset == 25) begin
          if(cmem_byte_enable[0]) word_sel_out[207:200] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[215:208] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[223:216] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[231:224] = cmem_wdata[31:24];
       end
       else if(offset == 26) begin
          if(cmem_byte_enable[0]) word_sel_out[215:208] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[223:216] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[231:224] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[239:232] = cmem_wdata[31:24];
       end
       else if(offset == 27) begin
          if(cmem_byte_enable[0]) word_sel_out[223:216] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[231:224] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[239:232] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[247:240] = cmem_wdata[31:24];
       end
       else if(offset == 28) begin
          if(cmem_byte_enable[0]) word_sel_out[231:224] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[239:232] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[247:240] = cmem_wdata[23:16];
          if(cmem_byte_enable[3]) word_sel_out[255:248] = cmem_wdata[31:24];
       end
       else if(offset == 29) begin
          if(cmem_byte_enable[0]) word_sel_out[239:232] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[247:240] = cmem_wdata[15:8];
          if(cmem_byte_enable[2]) word_sel_out[255:248] = cmem_wdata[23:16];
       end
       else if(offset == 30) begin
          if(cmem_byte_enable[0]) word_sel_out[247:240] = cmem_wdata[7:0];
          if(cmem_byte_enable[1]) word_sel_out[255:248] = cmem_wdata[15:8];
       end
       else if(offset == 31) begin
          if(cmem_byte_enable[0]) word_sel_out[255:248] = cmem_wdata[7:0];
       end
    end // always_comb

endmodule : word_sel
