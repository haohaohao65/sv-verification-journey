class Coverage#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
logic rst_n;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0]wr_data;
logic [DATA_WIDTH-1:0]rd_data;
logic full;
logic empty;
logic [$clog2(DEPTH+1)-1:0] count;
mailbox mb_cov;

covergroup cg();

cp_a: coverpoint rst_n{
    bins rst_n0={0};
    bins rst_n1={1};
}

cp_b: coverpoint wr_en{
    bins wr_en0={0};
    bins wr_en1={1};
}

cp_c: coverpoint rd_en{
    bins rd_en0={0};
    bins rd_en1={1};
}

cp_d: coverpoint wr_data{
    bins zero={0};
    bins low={[1:10]};
    bins middle={[11:245]};
    bins high={[246:254]};
    bins max={255};
}

cp_e: coverpoint full{
    bins full0={0};
    bins full1={1};
}

cp_f: coverpoint empty{
    bins empty0={0};
    bins empty1={1};
}

cp_g: coverpoint count{
    bins count0={0};
    bins count1={[1:15]};
    bins count2={16};
}

cross cp_b,cp_c;
cross cp_a,cp_b,cp_c;
cross cp_b,cp_e;
cross cp_c,cp_f;

endgroup


function new(mailbox mb_cov);
this.mb_cov=mb_cov;
cg=new();
endfunction

task run();

repeat(1000) begin
    mb_cov.get(tr);

    rst_n=tr.rst_n;
    wr_en=tr.wr_en;
    rd_en=tr.rd_en;
    wr_data=tr.wr_data;
    rd_data=tr.rd_data;
    full=tr.full;
    empty=tr.empty;
    count=tr.count;

    cg.sample();

end

endtask


endclass