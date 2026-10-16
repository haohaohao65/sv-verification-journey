class fifo_simultaneous_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_simultaneous_sequence);

function new(string name = "fifo_simultaneous_sequence");
super.new(name);
endfunction

virtual task body();

fifo_item seq;

seq = fifo_item::type_id::create("seq");

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 1;
finish_item(seq);

start_item(seq);
seq.w_enb = 0;
seq.r_enb = 1;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hAAAA;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hBBBB;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hCCCC;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 16'hAABB;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 16'hBBAA;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 16'hABCD;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 16'hEEEE;
finish_item(seq);

repeat(3) begin
start_item(seq);
seq.w_enb = 0;
seq.r_enb = 1;
finish_item(seq);
end

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hEEEE;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hBBBB;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hECDA;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hAACE;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hEBDE;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hAAEE;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hDDBA;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 0;
seq.din = 16'hABBB;
finish_item(seq);

start_item(seq);
seq.w_enb = 1;
seq.r_enb = 1;
seq.din = 16'hAAAA;
finish_item(seq);

repeat(7) begin
    start_item(seq);
seq.w_enb = 0;
seq.r_enb = 1;
finish_item(seq);
end

endtask

endclass