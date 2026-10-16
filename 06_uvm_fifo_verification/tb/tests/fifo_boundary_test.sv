class fifo_boundary_test extends fifo_test;

`uvm_component_utils(fifo_boundary_test);

function new(string name,uvm_component parent);
super.new(name,parent);
expected_write = 8;
expected_read = 8;
write_request_count = 10;
read_request_count = 10;
endfunction

virtual task run_sequence();
seq = fifo_boundary_sequence::type_id::create("seq");
endtask

endclass