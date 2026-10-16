class fifo_scoreboard extends uvm_scoreboard;

`uvm_component_utils(fifo_scoreboard);

localparam int Depth = 8;
localparam int Width = 16;

uvm_tlm_analysis_fifo #(fifo_sample) sample_fifo;
fifo_sample sco_sam;
fifo_sample expected_sam;

logic [Width-1:0] ref_q[$];
logic can_write;
logic can_read;
logic [Width-1:0]last_dout;
logic reject_write;
logic reject_read;
logic both_empty;
logic both_middle;
logic both_full;

int checked_count = 0;
int write_count = 0;
int read_count = 0;
int write_request_count = 0;
int read_request_count = 0;
int rejected_write_count = 0;
int rejected_read_count = 0;
int reset_count = 0;

int both_empty_count = 0;
int both_middle_count = 0;
int both_full_count = 0;
int both_count;


function fifo_sample predict(input fifo_sample sco_sam);
fifo_sample t;

t = fifo_sample::type_id::create("t");

can_write = (sco_sam.w_enb) && (ref_q.size() < Depth);
can_read = sco_sam.r_enb && (ref_q.size() > 0);
reject_write = !can_write && sco_sam.w_enb;
reject_read = !can_read && sco_sam.r_enb;
both_empty = (ref_q.size() == 0 && sco_sam.w_enb && sco_sam.r_enb);
both_middle = (can_write && can_read);
both_full = (ref_q.size() == Depth && sco_sam.w_enb && sco_sam.r_enb);

if(sco_sam.reset) begin
    ref_q.delete();
    last_dout = 0;
end
else
begin
    if(can_write) begin
        if($isunknown(sco_sam.din)) begin
            `uvm_fatal("fifo_scoreboard fatal","sco_sam.din isunknown");
        end

    ref_q.push_back(sco_sam.din);
    write_count++;
    write_request_count++;
    end
    else if(reject_write) begin
    rejected_write_count++;
    write_request_count++;
    end
    if(can_read) begin
    last_dout = ref_q.pop_front();
    read_count++;
    read_request_count++;
    end
    else if(reject_read) begin
    rejected_read_count++; 
    read_request_count++;
    end
    if(both_middle) begin
            both_middle_count++;
        end
    if(both_empty) begin
            both_empty_count++;
        end
    if(both_full) begin
            both_full_count++;
         end

end

t.dout = last_dout;
t.empty = (ref_q.size() == 0);
t.full = (ref_q.size() == Depth);

both_count = both_empty_count+both_middle_count+both_full_count;

return t;

endfunction


function new(string name,uvm_component parent);
super.new(name,parent);
endfunction


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

sample_fifo = new("sample_fifo",this);
endfunction


virtual task run_phase(uvm_phase phase);
super.run_phase(phase);

forever begin
    sample_fifo.get(sco_sam);
    if($isunknown({sco_sam.reset, sco_sam.w_enb, sco_sam.r_enb})) begin
        `uvm_fatal("fifo_scoreboard fatal","sco_sam isunknown");
    end

    if(sco_sam.is_reset_event === 1) begin
        reset_count++;
    end

    expected_sam = predict(sco_sam);

    if((expected_sam.dout !== sco_sam.dout) || 
       (expected_sam.empty !== sco_sam.empty) ||
       (expected_sam.full !== sco_sam.full)) begin
        `uvm_fatal("fifo_scoreboard fatal","sco_sam != expected");
        checked_count++;
    end
    else begin
    $display("pass");
    checked_count++;
    end

end

endtask

endclass