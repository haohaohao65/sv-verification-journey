class fifo_simultaneous_test extends fifo_test;

`uvm_component_utils(fifo_simultaneous_test);

function new(string name,uvm_component parent);
super.new(name,parent);

expected_write = 16;
expected_read = 16;
write_request_count = 17;
read_request_count = 17;
both_empty_count = 1;
both_middle_count = 4;
both_full_count = 1;
endfunction

virtual task run_sequence();
seq = fifo_simultaneous_sequence::type_id::create("seq");
endtask

endclass