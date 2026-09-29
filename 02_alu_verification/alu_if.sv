interface alu_if(input logic clk);

logic [7:0]a;
logic [7:0]b;
logic [1:0]op;
logic [7:0]result;

clocking cb @(posedge clk);

output a;
output b;
output op;
input result;

endclocking

clocking mon_cb @(posedge clk);

    input a;
    input b;
    input op;
    input result;

endclocking


modport Monitor_if(
    input a,
    input b,
    input op,
    input result
);

modport dut_if(
     input a,
    input b,
    input op,
    output result
);

endinterface