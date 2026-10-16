class fifo_wrap_test extends fifo_test;

`uvm_component_utils(fifo_wrap_test);

function new(string name,uvm_component parent);
super.new(name,parent);

expected_write = 32;
expected_read = 32;
write_request_count = 32;
read_request_count = 32;
both_empty_count = 0;
both_middle_count = 0;
both_full_count = 0;
endfunction

virtual task run_sequence();
seq = fifo_wrap_sequence::type_id::create("seq");
endtask

endclass