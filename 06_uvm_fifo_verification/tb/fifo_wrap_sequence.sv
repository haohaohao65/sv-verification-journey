class fifo_wrap_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_wrap_sequence);

function new(string name = "fifo_wrap_sequence");
super.new(name);
endfunction


virtual task body();
fifo_item req;

req = fifo_item::type_id::create("req");

for(int i=0;i<8;i++) begin
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h0 + i;
finish_item(req);
end

repeat(8) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

for(int i=0;i<8;i++) begin
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'h1111 + i;
finish_item(req);
end

repeat(8) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

for(int i=0;i<8;i++) begin
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'hAAAA + i;
finish_item(req);
end

repeat(8) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

for(int i=0;i<8;i++) begin
start_item(req);
req.w_enb = 1;
req.r_enb = 0;
req.din = 16'hBBBB + i;
finish_item(req);
end

repeat(8) begin
start_item(req);
req.w_enb = 0;
req.r_enb = 1;
finish_item(req);
end

endtask

endclass