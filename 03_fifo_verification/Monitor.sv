class Monitor#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
mailbox mb_sco;
mailbox mb_cov;
virtual fifo_if f_if;
logic p_rst_n;
logic p_wr_en;
logic p_rd_en;
logic [DATA_WIDTH-1:0]p_wr_data;
bit first;

function new(mailbox mb_sco,mailbox mb_cov,virtual fifo_if f_if);
this.mb_sco=mb_sco;
this.mb_cov=mb_cov;
this.f_if=f_if;
endfunction

task run();

first = 1;
p_rst_n   = 0;
p_wr_en   = 0;
p_rd_en   = 0;
p_wr_data = '0;

repeat(1001) begin
    @(f_if.mon_cb);


if(!first) begin
    tr=new();
    tr.rst_n=p_rst_n;
    tr.wr_en=p_wr_en;
    tr.rd_en=p_rd_en;
    tr.wr_data=p_wr_data;
    tr.rd_data=f_if.mon_cb.rd_data;
    tr.full=f_if.mon_cb.full;
    tr.empty=f_if.mon_cb.empty;
    tr.count=f_if.mon_cb.count;
    
   // tr.display("Monitor");

    mb_sco.put(tr);
    mb_cov.put(tr.copy());
end

    p_rst_n=f_if.mon_cb.rst_n;
    p_wr_en=f_if.mon_cb.wr_en;
    p_rd_en=f_if.mon_cb.rd_en;
    p_wr_data=f_if.mon_cb.wr_data;

    first=0;

end

endtask

endclass