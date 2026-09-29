class Coverage;

logic [7:0]a;
logic [7:0]b;
logic [1:0]op;
logic [7:0]result;
mailbox mb_cov;
Transaction tr;

covergroup cg;

cp_a: coverpoint a{
    bins a0={0};
    bins a1={[1:254]};
    bins a2={255};
}

cp_b: coverpoint b{
    bins b0={0};
    bins b1={[1:254]};
    bins b2={255};
}

cp_op: coverpoint op{
    bins op0={0};
    bins op1={1};
    bins op2={2};
    bins op3={3};
}

cross cp_op, cp_a, cp_b{
    ignore_bins normal_nor=
       binsof(cp_op.op3)&&binsof(cp_b.b1)&&binsof(cp_a.a1);
}

endgroup


function new(mailbox mb_cov);
this.mb_cov=mb_cov;
cg=new();
endfunction

task run();

repeat(100) begin
    mb_cov.get(tr);
    a=tr.a;
    b=tr.b;
    op=tr.op;
    result=tr.result;

    cg.sample();

end

endtask

endclass