class fifo_random_test extends fifo_test;

`uvm_component_utils(fifo_random_test);

int both_count;
int transaction_count;

fifo_random_sequence random_seq;

function new(string name,uvm_component parent);
super.new(name,parent);
endfunction

virtual task run_sequence();
random_seq =  fifo_random_sequence::type_id::create("random_seq");
seq = random_seq;
endtask


virtual function void check_traffic();
write_request_count = random_seq.w_enb_count;
read_request_count = random_seq.r_enb_count ;
both_count = random_seq.simultaneous_enb_count;
transaction_count = random_seq.transaction_count;

if(env.sco.write_count + env.sco.rejected_write_count !== write_request_count) begin
    `uvm_error("test check fatal","env.sco.write_count + env.sco.rejected_write_count !== write_request_count");
end
if(env.sco.read_count + env.sco.rejected_read_count !== read_request_count) begin
    `uvm_error("test check fatal","env.sco.read_count + env.sco.rejected_read_count !== read_request_count");
end
if(env.sco.write_count !== env.sco.read_count) begin
    `uvm_error("test check fatal","env.sco.expected_write !== env.sco.expected_read");
end
if(env.sco.write_request_count !== write_request_count) begin
    `uvm_error("test check fatal","env.sco.write_request_count !== write_request_count");
end 
if(env.sco.read_request_count !== read_request_count) begin
    `uvm_error("test check fatal","env.sco.read_request_count !== read_request_count");
end 
if(env.sco.both_count !== both_count) begin
    `uvm_error("test check fatal","env.sco.both_count !== both_count");
end 
if(transaction_count !== 208) begin
    `uvm_error("test check fatal","transaction_count !== 208");
end 
endfunction

endclass