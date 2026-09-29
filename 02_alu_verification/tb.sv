`include "Transaction.sv"
`include "Generator.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "ReferenceModel.sv"
`include "Scoreboard.sv"
`include "Coverage.sv"
`include "Environment.sv"

module tb;

logic clk;
initial clk=0;
always #5ns clk=~clk;

alu_if a_if(clk);

alu d1(.a_if(a_if));

Environment env;

initial begin
    env=new(a_if);
    env.run();
    $display("===================\nTOTAL : %0d\nPASS  : %0d\nFAIL  : %0d\n===================",
          env.sco.total,
          env.sco.pass,
          env.sco.fail);
    $display("Coverage=%0f", env.cov.cg.get_coverage());
    $finish;
end

endmodule