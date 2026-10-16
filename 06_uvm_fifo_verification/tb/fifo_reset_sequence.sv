class fifo_reset_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_reset_sequence);

function new(string name = "fifo_reset_sequence");
super.new(name);
endfunction


virtual task body();

fifo_item req;

req = fifo_item::type_id::create("req");

start_item(req);
req.w_enb = 1;
req.din = 16'hA001;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.din = 16'hA002;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.din = 16'hA003;
finish_item(req);

start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);

start_item(req);
req.reset_req = 1;
req.r_enb = 0;
finish_item(req);

start_item(req);
req.reset_req = 0;
req.r_enb = 1;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.r_enb=0;
req.din = 16'hB001;
finish_item(req);

start_item(req);
req.w_enb = 1;
req.r_enb=0;
req.din = 16'hB002;
finish_item(req);

start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);

start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);

endtask

endclass