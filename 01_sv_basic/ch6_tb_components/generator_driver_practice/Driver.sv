class Driver;

    Transaction tr;
    mailbox mb;

    function new(mailbox mb);
        this.mb = mb;
    endfunction

    task run();

        repeat(10) begin
        mb.get(tr);
        tr.display("Driver");
        end

    endtask

endclass