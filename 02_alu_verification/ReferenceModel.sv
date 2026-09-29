class ReferenceModel;

function logic [7:0] calculate(logic [7:0]a,logic [7:0]b,logic [1:0]op);

case(op)
2'b00:return a+b;
2'b01:return a-b;
2'b10:return a&b;
2'b11:return a^b;
endcase

endfunction

endclass