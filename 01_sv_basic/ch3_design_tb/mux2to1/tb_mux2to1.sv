module tb_mux2to1;
logic a;
logic b;
logic sel;
logic y;

dut_mux2to1 dut(
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);

task check_result(input logic a,input logic b);
if(a!==b)
$display("FAIL");
else
$display("PASS");
endtask

task drive(input logic x,input logic y,input logic z);
a=x;
b=y;
sel=z;
#0;
endtask

task test_case(input logic in_a,input logic in_b,input logic in_sel);
bit expected;
expected=in_sel?in_b:in_a;
drive(in_a,in_b,in_sel);
check_result(y,expected);
endtask

initial begin
   test_case(0,0,0);

    #10ns 
    test_case(0,1,0);

    #10ns 
    test_case(0,1,1);

    #10ns 
    test_case(1,0,1);
end

endmodule