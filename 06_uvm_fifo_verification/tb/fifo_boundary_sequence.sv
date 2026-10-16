class fifo_boundary_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_boundary_sequence);

function new(string name = "fifo_boundary_sequence");
super.new(name);
endfunction

virtual task body();

fifo_item req;

req =fifo_item::type_id::create("req");


for(int i = 1;i<11;i++) begin
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1000+i;
finish_item(req);
end

repeat(10) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

endtask

endclass