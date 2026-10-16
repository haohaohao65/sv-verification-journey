class fifo_monitor extends uvm_monitor;

`uvm_component_utils(fifo_monitor);

localparam int Depth = 8;
localparam int Width = 16;

uvm_analysis_port #(fifo_sample) ap;
virtual fifo_if#(.Depth(Depth),.Width(Width)) vif;
fifo_sample sam;
fifo_sample sam_reset;

int published_count = 0;

function new(string name,uvm_component parent);
super.new(name,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

if(!uvm_config_db #(virtual fifo_if #(.Depth(Depth), .Width(Width)))::get(this,"","vif",vif)) begin
    `uvm_fatal("fifo_monitor build config fatal","uvm_config_db fail");
end
if(vif == null) begin
    `uvm_fatal("fifo_monitor build config fatal","uvm_config_db fail");
end

ap = new("ap",this);
endfunction


virtual task run_phase(uvm_phase phase);
super.run_phase(phase);

    fork
        begin 
    forever begin
    @(vif.mon_cb);
    sam = fifo_sample::type_id::create("sam");
    sam.reset = vif.mon_cb.reset;
    sam.w_enb = vif.mon_cb.w_enb;
    sam.r_enb = vif.mon_cb.r_enb;
    sam.din = vif.mon_cb.din;
    sam.dout = vif.mon_cb.dout;
    sam.empty = vif.mon_cb.empty;
    sam.full = vif.mon_cb.full;
    sam.pre_empty = vif.mon_cb.pre_empty;
    sam.pre_full = vif.mon_cb.pre_full;

$display("[%0t]sam:reset=%0d,w_enb=%0d,r_enb=%0d,din=%0h,dout=%0h,empty=%0d,full=%0d",
          $time,sam.reset,sam.w_enb,sam.r_enb,sam.din,sam.dout,sam.empty,sam.full);

    ap.write(sam);
    published_count++;
    end
        end
        begin
forever begin
    wait(vif.reset === 0);
    @(vif.reset_cb);
    sam_reset = fifo_sample::type_id::create("sam_reset");
    sam_reset.w_enb = 0;
    sam_reset.r_enb = 0;
    sam_reset.is_reset_event = 1;
    sam_reset.reset = vif.reset_cb.reset;
    sam_reset.dout = vif.reset_cb.dout;
    sam_reset.empty = vif.reset_cb.empty;
    sam_reset.full = vif.reset_cb.full;
    
    $display("is_reset_event");

$display("[%0t]sam_reset:reset=%0d,w_enb=%0d,r_enb=%0d,din=%0h,dout=%0h,empty=%0d,full=%0d",
          $time,sam_reset.reset,sam_reset.w_enb,sam_reset.r_enb,sam_reset.din,sam_reset.dout,sam_reset.empty,sam_reset.full);

    ap.write(sam_reset);

    published_count++;
end
        end
    join

endtask

endclass