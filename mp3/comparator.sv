// A module for the simple comparator

module comparator #(parameter width = 24)(
    input [width-1:0] a,
    input [width-1:0] b,
    input valid_bit,
    output logic equal
    );

    always_comb
    begin
        if (a == b)
            equal = valid_bit;
        else
            equal = 1'b0;
    end

endmodule : comparator
