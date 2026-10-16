class fifo_item extends uvm_sequence_item;

`uvm_object_utils(fifo_item);

localparam int Depth = 8;
localparam int Width = 16;

rand bit w_enb;
rand bit r_enb;
rand bit [Width-1:0]din;

bit reset_req = 0;

bit no_gap = 0;

function new(string name = "fifo_item");
super.new(name);
endfunction

constraint din_c{
    din dist{
         16'h0 := 1,
         [16'h1:16'hFFFE] :/ 8,
         16'hFFFF := 1
    };
}

endclass