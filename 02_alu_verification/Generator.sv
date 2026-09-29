class Generator;

Transaction tr;
mailbox mb;

function new(mailbox mb);
this.mb=mb;
endfunction


task send_directed(
    logic [7:0]a_val,
    logic [7:0]b_val,
    logic [1:0]op_val
);
tr=new();

assert(tr.randomize() with {
    a == a_val;
    b == b_val;
    op == op_val;
});

mb.put(tr);

endtask


task send_range_a(
    logic [7:0]b_val,
    logic [1:0]op_val
);

tr=new();

assert(tr.randomize() with {
    a inside {[1:254]};
    b == b_val;
    op ==op_val;
});

mb.put(tr);

endtask


task send_range_b(
    logic [7:0]a_val,
    logic [1:0]op_val
);

tr=new();

assert(tr.randomize() with {
    a == a_val;
    b inside {[1:254]};
    op ==op_val;
});

mb.put(tr);

endtask



task run();

repeat(68) begin
tr=new();
assert(tr.randomize());
tr.display("Generator");
mb.put(tr);
end


send_directed(0,0,0);

send_directed(0,255,0);

send_directed(255,0,0);

send_directed(255,255,0);

send_directed(0,0,1);

send_directed(0,255,1);

send_directed(255,0,1);

send_directed(255,255,1);

send_directed(0,0,2);

send_directed(0,255,2);

send_directed(255,0,2);

send_directed(255,255,2);

send_directed(0,0,3);

send_directed(0,255,3);

send_directed(255,0,3);

send_directed(255,255,3);

send_range_a(0,0);

send_range_a(255,0);

send_range_a(0,1);

send_range_a(255,1);

send_range_a(0,2);

send_range_a(255,2);

send_range_a(0,3);

send_range_a(255,3);

send_range_b(0,0);

send_range_b(255,0);

send_range_b(0,1);

send_range_b(255,1);

send_range_b(0,2);

send_range_b(255,2);

send_range_b(0,3);

send_range_b(255,3);

endtask

endclass