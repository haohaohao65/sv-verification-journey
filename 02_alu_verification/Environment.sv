class Environment;

Generator gen;
Driver dri;
Monitor mon;
Scoreboard sco;
mailbox mb_gen;
mailbox mb_mon;
virtual alu_if a_if;
Coverage cov;
mailbox mb_cov;

function new(virtual alu_if a_if);
this.a_if=a_if;
mb_gen=new();
mb_mon=new();
mb_cov=new();
cov=new(mb_cov);
gen=new(mb_gen);
dri=new(mb_gen,a_if);
mon=new(mb_mon,a_if,mb_cov);
sco=new(mb_mon);
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