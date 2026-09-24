`include "Transaction.sv"
`include "Generator.sv"
`include "Driver.sv"

module tb;

logic clk;
initial clk=0;
always #5ns clk=~clk;

mailbox mb;
Generator gen;
Driver dri;

add_if a_if(clk);
 add d1(.a_if(a_if));

 initial begin
    mb=new();
    gen=new(mb);
    dri=new(mb,a_if);
    @(posedge clk);
    
    fork
        gen.run();
        dri.run();
    join
 end

endmodule