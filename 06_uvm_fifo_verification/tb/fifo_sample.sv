class fifo_sample extends uvm_object;

`uvm_object_utils(fifo_sample);

localparam int Depth = 8;
localparam int Width = 16;

logic reset;
logic w_enb;
logic r_enb;
logic [Width-1:0]din;
logic [Width-1:0]dout;
logic empty;
logic full;
logic pre_empty;
logic pre_full;

bit is_reset_event = 0;

function new(string name = "fifo_sample");
super.new(name);
endfunction

endclass