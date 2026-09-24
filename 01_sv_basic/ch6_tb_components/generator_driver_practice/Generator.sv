`include "Transaction.sv"

class Generator;

Transaction tr;
mailbox mb;

function new(mailbox mb);
this.mb=mb;
endfunction

task run();

repeat(10) begin
tr=new();
assert(tr.randomize());
tr.display("Generator");
mb.put(tr);
#10ns;
end

endtask

endclass