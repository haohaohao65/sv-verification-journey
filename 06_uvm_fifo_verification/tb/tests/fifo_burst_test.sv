class fifo_burst_test extends fifo_test;

`uvm_component_utils(fifo_burst_test);

function new(string name,uvm_component parent);
super.new(name,parent);
expected_write = 8;
expected_read = 8;
write_request_count = 8;
read_request_count = 8;
endfunction


virtual task run_sequence();
seq =  fifo_burst_sequence::type_id::create("seq");
endtask


endclass