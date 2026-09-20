interface handshake_if(input logic clk);

    logic       rst_n;
    logic       valid;
    logic       ready;
    logic [7:0] data;

modport dut_mp(
    input clk,
    input rst_n,
    input valid,
    input data,
    output ready
);

modport checker_mp(
    input clk,
    input rst_n,
    input valid,
    input data,
    input ready
);

endinterface