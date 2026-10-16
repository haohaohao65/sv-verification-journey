class fifo_burst_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_burst_sequence);

function new(string name = "fifo_burst_sequence");
super.new(name);
endfunction


virtual task body();

fifo_item seq;

seq = fifo_item::type_id::create("seq");


for(int i = 0;i<8;i++) begin
start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'h1001 + i;
if(i == 7)
seq.no_gap = 0;
else
seq.no_gap = 1;
finish_item(seq);
end

for(int i = 0;i<8;i++) begin
start_item(seq);
seq.w_enb = 0;
seq.r_enb = 1;
if(i == 7)
seq.no_gap = 0;
else
seq.no_gap = 1;
finish_item(seq);
end

endtask

endclass