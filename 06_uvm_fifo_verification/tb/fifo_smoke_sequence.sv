class fifo_smoke_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_smoke_sequence);

function new(string name = "fifo_smoke_sequence");
super.new(name);
endfunction


virtual task body();
fifo_item req;

req = fifo_item::type_id::create("req");
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'hAAAA;
finish_item(req);

start_item(req);
req.w_enb = 0;
req.r_enb = 1;
req.din = 0;
finish_item(req);

endtask

endclass