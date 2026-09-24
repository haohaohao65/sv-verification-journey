interface add_if(input logic clk);

logic [7:0]a;
logic [7:0]b;
logic [7:0]y;


modport add_mp(
    input a,
    input b,
    output y
);

modport Driver_mp(
    output a,
    output b
);

endinterface