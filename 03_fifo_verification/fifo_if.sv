interface fifo_if#(parameter DATA_WIDTH=8,parameter DEPTH=16)(input logic clk);

logic rst_n;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0]wr_data;
logic [DATA_WIDTH-1:0]rd_data;
logic full;
logic empty;
logic [$clog2(DEPTH+1)-1:0] count;

clocking dri_cb @(posedge clk);
default input #1step output #0;
output rst_n;
output wr_en;
output rd_en;
output wr_data;

endclocking

clocking mon_cb @(posedge clk);
default input #1step output #0;
input rst_n;
input wr_en;
input rd_en;
input wr_data;
input rd_data;
input full;
input empty;
input count;

endclocking

modport dut_if(
    input clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input wr_data,
    output rd_data,
    output full,
    output empty,
    output count
);



endinterface