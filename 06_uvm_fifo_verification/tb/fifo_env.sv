class fifo_env extends uvm_env;

`uvm_component_utils(fifo_env);

localparam int Depth = 8;
localparam int Width = 16;

fifo_agent agt;
fifo_scoreboard sco;
fifo_coverage cov;

virtual fifo_if#(
    .Depth(Depth),
    .Width(Width)
 ) vif;

function new(string name,uvm_component parent);
super.new(name,parent);
endfunction


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

agt = fifo_agent::type_id::create("agt",this);
sco = fifo_scoreboard::type_id::create("sco",this);
cov = fifo_coverage::type_id::create("cov",this);

endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);

agt.mon.ap.connect(sco.sample_fifo.analysis_export);
agt.mon.ap.connect(cov.analysis_export);

endfunction

endclass