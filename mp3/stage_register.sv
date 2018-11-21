module stage_register #(parameter width = 32)
(
    input clk,
    input load,
	 input reset,
    input [width-1:0] in,
    output logic [width-1:0] out
);

logic [width-1:0] data;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 0;
end

always_ff @(posedge clk)
begin
	 if (reset) begin 
		  data = 0;
    end else if (load) begin
        data = in;
    end
end

always_comb
begin
    out = data;
end

endmodule : stage_register
