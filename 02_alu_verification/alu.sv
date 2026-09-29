module alu(
    alu_if.dut_if a_if
);

always @(*) begin
case(a_if.op)
2'b00:a_if.result=a_if.a+a_if.b;
2'b01:a_if.result=a_if.a-a_if.b;
2'b10:a_if.result=a_if.a&a_if.b;
2'b11:a_if.result=a_if.a^a_if.b;
endcase
end

endmodule