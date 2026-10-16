class fifo_random_sequence extends uvm_sequence#(fifo_item);

`uvm_object_utils(fifo_random_sequence);

int transaction_count = 0;
int w_enb_count = 0;
int r_enb_count = 0;
int simultaneous_enb_count = 0;

function new(string name = "fifo_random_sequence");
super.new(name);
endfunction


virtual task body();

fifo_item req;

req = fifo_item::type_id::create("req");

repeat(200) begin
    start_item(req);
    if(!req.randomize()) begin
        `uvm_fatal("fifo_random_sequence fatal","req.randomize()");
    end

    if(req.w_enb) begin
        w_enb_count++;
    end
    if(req.r_enb) begin
        r_enb_count++;
    end
    if(req.w_enb && req.r_enb) begin
        simultaneous_enb_count++;
    end

    transaction_count++;

    finish_item(req);
end

repeat(8) begin
    start_item(req);
    req.w_enb = 0;
    req.r_enb = 1;
    req.din = 0;
    r_enb_count++;
    transaction_count++;
    finish_item(req);
end

endtask

endclass