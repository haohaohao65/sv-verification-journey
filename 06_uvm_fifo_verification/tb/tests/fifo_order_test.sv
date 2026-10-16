class fifo_order_test extends fifo_test;

`uvm_component_utils(fifo_order_test);

function new(string name,uvm_component parent);
super.new(name,parent);
expected_write = 4;
expected_read = 4;
write_request_count = 4;
read_request_count = 4;
endfunction

virtual task run_sequence();
seq = fifo_order_sequence::type_id::create("seq");
endtask

endclass