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

initial begin
    a=0;
    b=0;
    sel=0;
    #0
    $display ("y=%0d",y);
   check_result(y,expected);

    #10ns 
    a=0;
    b=1;
    sel=0;
    #0
    $display ("y=%0d",y);
    check_result(y,expected);

    #10ns 
    a=0;
    b=1;
    sel=1;
    #0
    $display ("y=%0d",y);
    check_result(y,expected);

    #10ns 
    a=1;
    b=0;
    sel=1;
    #0
    $display ("y=%0d",y);
    check_result(y,expected);
end

endmodule