class Driver;

Transaction tr;
mailbox mb;

virtual add_if a_if;

function new(mailbox mb, virtual add_if a_if);
    this.mb = mb;
    this.a_if = a_if;
endfunction

task run();

    repeat(10) begin
        mb.get(tr);
        tr.display("Driver");

        a_if.a = tr.a;
        a_if.b = tr.b;
    end

endtask

endclass