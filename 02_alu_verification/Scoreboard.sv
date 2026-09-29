class Scoreboard;

Transaction tr;
mailbox mb;
ReferenceModel ref_model;
int total=0;
int pass=0;
int fail=0;

function new(mailbox mb);
this.mb=mb;
this.ref_model=new();
endfunction

task run();

repeat(100) begin
    mb.get(tr);
    total=total+1;
    if(tr.result==ref_model.calculate(tr.a,tr.b,tr.op)) begin
    $display("pass");
    pass=pass+1;
    end
    else begin
    $display("Error");
    fail=fail+1;
    end
end

endtask

endclass