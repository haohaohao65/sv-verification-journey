interface fifo_if#(
    parameter Depth = 8,
    parameter Width = 16 
    ) (
        input logic clk
    );

    logic reset;
    logic w_enb;
    logic r_enb;
    logic [Width-1:0] din;
    logic [Width-1:0] dout;
    logic empty;
    logic full;

clocking dri_cb @(negedge clk);
default input #1step output #0;
    output w_enb;
    output r_enb;
    output din;
endclocking


clocking mon_cb @(posedge clk);
    input #1step reset;
    input #1step w_enb;
    input #1step  r_enb;
    input #1step din;
    input #0 dout;
    input #0 empty;
    input #0 full;
    input #1step pre_empty = empty;
    input #1step pre_full = full;
endclocking


clocking reset_cb @(posedge reset);
default input #0;
    input reset;
    input dout;
    input empty;
    input full;
endclocking

endinterface