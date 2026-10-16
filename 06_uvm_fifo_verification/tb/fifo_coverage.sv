class fifo_coverage extends uvm_subscriber#(fifo_sample);

`uvm_component_utils(fifo_coverage);

fifo_sample cov_sam;

covergroup fifo_cg();

cg_a: coverpoint {cov_sam.w_enb,cov_sam.r_enb}{
    bins free = {2'b00};
    bins only_read = {2'b01};
    bins only_write = {2'b10};
    bins read_and_write = {2'b11};
}

cg_b: coverpoint cov_sam.din iff(cov_sam.w_enb){
    bins din0 = {16'h0};
    bins din1 = {16'hFFFF};
    bins din2 = {[1:16'hFFFE]};
}

cg_c: coverpoint {cov_sam.pre_empty,cov_sam.pre_full}{
    bins count0 = {2'b10};
    bins count1 = {2'b00};
    bins count2 = {2'b01};
}

op_x_data:cross cg_a,cg_b iff(cov_sam.w_enb){ignore_bins free_onlyread = binsof(cg_a.free) || binsof(cg_a.only_read);}
op_x_count:cross cg_a,cg_c;
endgroup


function new(string name,uvm_component parent);
super.new(name,parent);
fifo_cg = new();
endfunction


virtual function void write(fifo_sample t);
if((t.reset === 1'b0) && (t.is_reset_event === 1'b0)) begin
    cov_sam = t;
    fifo_cg.sample();
end
endfunction


virtual function void report_phase(uvm_phase phase);
real cov_report;

super.report_phase(phase);

cov_report = fifo_cg.get_inst_coverage();

$display("coverage = %0f",cov_report);
endfunction

endclass