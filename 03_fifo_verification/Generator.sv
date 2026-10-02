class Generator#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
mailbox mb_gen;

function new(mailbox mb_gen);
this.mb_gen=mb_gen;
endfunction


task run();

repeat(1000) begin
tr=new();
assert(tr.randomize());
tr.display("Generator");
mb_gen.put(tr);
end

endtask

endclass