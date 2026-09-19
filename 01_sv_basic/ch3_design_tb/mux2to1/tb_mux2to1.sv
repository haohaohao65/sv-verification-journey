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

bit expected;
assign expected=sel?b:a;

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

initial begin
   drive(0,0,0);
   check_result(y,expected);

    #10ns 
    drive(0,1,0);
    check_result(y,expected);

    #10ns 
    drive(0,1,1);
    check_result(y,expected);

    #10ns 
    drive(1,0,1);
    check_result(y,expected);
end

endmodule