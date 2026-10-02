class Driver#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
mailbox  mb_gen;
virtual fifo_if f_if;

function new(mailbox mb_gen,virtual fifo_if f_if);
this.mb_gen=mb_gen;
this.f_if=f_if;
endfunction

task run();


repeat(1000) begin

    mb_gen.get(tr);
    tr.display("Driver");

    f_if.dri_cb.rst_n<=tr.rst_n;
    f_if.dri_cb.wr_en<=tr.wr_en;
    f_if.dri_cb.rd_en<=tr.rd_en;
    f_if.dri_cb.wr_data<=tr.wr_data;

    @(f_if.dri_cb);

end

endtask

endclass