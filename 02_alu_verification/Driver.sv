class Driver;

Transaction tr;
mailbox mb;
virtual alu_if a_if;

function new(mailbox mb,virtual alu_if a_if);
this.mb=mb;
this.a_if=a_if;
endfunction

task run();

repeat(100) begin
    @(a_if.cb);
    mb.get(tr);
    tr.display("Driver");
    a_if.cb.a<=tr.a;
    a_if.cb.b<=tr.b;
    a_if.cb.op<=tr.op;
end

endtask

endclass