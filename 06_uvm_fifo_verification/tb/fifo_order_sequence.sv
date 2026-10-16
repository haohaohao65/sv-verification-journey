class fifo_order_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_order_sequence);

function new(string name = "fifo_order_sequence");
super.new(name);
endfunction

virtual task body();

fifo_item req;

req = fifo_item::type_id::create("req");

start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1001;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1002;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1003;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1004;
finish_item(req);

repeat(4) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

endtask

endclass