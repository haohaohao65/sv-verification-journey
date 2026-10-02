class Environment#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Generator #(DATA_WIDTH,DEPTH)gen;
Driver #(DATA_WIDTH,DEPTH)dri;
Monitor #(DATA_WIDTH,DEPTH)mon;
Scoreboard #(DATA_WIDTH,DEPTH)sco;
mailbox mb_gen; 
mailbox mb_sco;
mailbox mb_cov;
Coverage #(DATA_WIDTH,DEPTH)cov;
virtual fifo_if f_if;

function new(virtual fifo_if f_if);

this.f_if=f_if;
mb_gen=new();
mb_sco=new();
mb_cov=new();
gen=new(mb_gen);
dri=new(mb_gen,f_if);
mon=new(mb_sco,mb_cov,f_if);
sco=new(mb_sco);
cov=new(mb_cov);

endfunction


task run();

fork
    gen.run();
    dri.run();
    mon.run();
    sco.run();
    cov.run();
join


endtask

endclass