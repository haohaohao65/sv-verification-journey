class fifo_reset_test extends fifo_test;

`uvm_component_utils(fifo_reset_test);

function new(string name,uvm_component parent);
super.new(name,parent);

expected_write = 5;
expected_read = 3;
write_request_count = 5;
read_request_count = 4;
both_empty_count = 0;
both_middle_count = 0;
both_full_count = 0;
expected_reset = 1;
endfunction


virtual task run_sequence();
seq = fifo_reset_sequence::type_id::create("seq");
endtask

endclass