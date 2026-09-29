class Monitor;

Transaction tr;
mailbox mb;
virtual alu_if a_if;
mailbox mb_cov;

function new(mailbox mb,virtual alu_if a_if,mailbox mb_cov);
this.mb=mb;
this.a_if=a_if;
this.mb_cov=mb_cov;
endfunction

task run();

@(a_if.mon_cb);

repeat(100) begin
    @(a_if.mon_cb);
    tr=new();
    tr.a=a_if.mon_cb.a;
    tr.b=a_if.mon_cb.b;
    tr.op=a_if.mon_cb.op;
    tr.result=a_if.mon_cb.result;
    tr.display("Monitor");
    mb.put(tr);
    mb_cov.put(tr.clone());
end

endtask

endclass