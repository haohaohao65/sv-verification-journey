class fifo_driver extends uvm_driver#(fifo_item);

`uvm_component_utils(fifo_driver);

localparam int Depth = 8;
localparam int Width = 16;

virtual fifo_if #(Depth,Width) vif;

function new(string name,uvm_component parent);
super.new(name,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

if(!uvm_config_db#(virtual fifo_if #(.Depth(Depth), .Width(Width)))::get(this,"","vif",vif)) begin
    `uvm_fatal("fifo_driver build config fatal","uvm_config_db fail");
end
if(vif == null)begin
    `uvm_fatal("fifo_driver build config fatal","uvm_config_db fail");
end
endfunction


virtual task run_phase(uvm_phase phase);
super.run_phase(phase);

wait(vif.reset === 0);

@(posedge vif.clk);

forever begin
    seq_item_port.get_next_item(req);
    if(req.reset_req) begin
    @(vif.dri_cb);
    vif.dri_cb.w_enb <= 0;
    vif.dri_cb.r_enb <= 0;
    vif.dri_cb.din <= 0;
    #2ns;
    vif.reset = 1;
    @(posedge vif.clk);
    @(vif.dri_cb);
    vif.reset = 0;
    @(posedge vif.clk);
    end else begin
    @(vif.dri_cb);
    vif.dri_cb.w_enb <= req.w_enb;
    vif.dri_cb.r_enb <= req.r_enb;
    vif.dri_cb.din <= req.din;
    if(!req.no_gap) begin
    @(vif.dri_cb);
    vif.dri_cb.w_enb <= 0;
    vif.dri_cb.r_enb <= 0;
    end
    end
    seq_item_port.item_done();
end

endtask


endclass