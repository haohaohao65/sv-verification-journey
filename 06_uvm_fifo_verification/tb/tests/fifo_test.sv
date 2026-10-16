class fifo_test extends uvm_test;

`uvm_component_utils(fifo_test);

localparam int Depth = 8;
localparam int Width = 16;

fifo_env env;
uvm_sequence #(fifo_item) seq;

int target_count;

int expected_write = 1;
int expected_read = 1;
int write_request_count = 1;
int read_request_count = 1;
int rejected_write_count;
int rejected_read_count;
int both_empty_count = 0;
int both_middle_count = 0;
int both_full_count = 0;

int expected_reset = 0;

virtual fifo_if #(
    .Depth(Depth),
    .Width(Width)
) vif;

function new(string name,uvm_component parent);
super.new(name,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

if(!uvm_config_db#(virtual fifo_if #(.Depth(Depth), .Width(Width)))::get(this,"","vif",vif)) begin
    `uvm_fatal("fifo_test build config fatal","uvm_config_db fail");
end
if(vif == null)begin
    `uvm_fatal("fifo_test build config fatal","uvm_config_db fail");
end

uvm_config_db#(virtual fifo_if #(.Depth(Depth), .Width(Width)))::set(this, "env.agt.dri", "vif", vif);
uvm_config_db#(virtual fifo_if #(.Depth(Depth), .Width(Width)))::set(this, "env.agt.mon", "vif", vif);

env = fifo_env::type_id::create("env",this);

endfunction


virtual task run_phase(uvm_phase phase);

phase.raise_objection(this);
$display("begin time = %0t",$time);

wait(vif.reset === 0);
$display("reset cancel,time = %0t",$time);
@(posedge vif.clk);

run_sequence();

seq.start(env.agt.sqr);

target_count = env.agt.mon.published_count + 1;
wait(env.sco.checked_count >= target_count);

$display("end time = %0t",$time);

phase.drop_objection(this);

endtask


virtual function void check_phase(uvm_phase phase);
super.check_phase(phase);

check_traffic();

if(env.sco.checked_count !== env.agt.mon.published_count) begin
    `uvm_error("test check fatal","checked_count != published_count");
end
if(env.sco.sample_fifo.used() !== 0) begin
    `uvm_error("test check fatal","sample_fifo.used() !== 0");
end
if(env.sco.reset_count !== expected_reset) begin
    `uvm_error("test check fatal","reset_count");
end
if(env.sco.ref_q.size() !== 0) begin
    `uvm_error("test check fatal","ref_q.size() !== 0");
end
endfunction


uvm_report_server server;

virtual function void report_phase(uvm_phase phase);
super.report_phase(phase);

server = uvm_report_server::get_server();
$display("published_count = %0d",env.agt.mon.published_count);
$display("checked_count = %0d",env.sco.checked_count);
$display("write_count = %0d",env.sco.write_count);
$display("read_count = %0d",env.sco.read_count);
$display("write_request_count = %0d",env.sco.write_request_count);
$display("read_request_count = %0d",env.sco.read_request_count);
$display("rejected_write_count = %0d",env.sco.rejected_write_count);
$display("rejected_read_count = %0d",env.sco.rejected_read_count);
$display("both_empty_count = %0d",env.sco.both_empty_count);
$display("both_middle_count = %0d",env.sco.both_middle_count);
$display("both_full_count = %0d",env.sco.both_full_count);
$display("reset_count = %0d",env.sco.reset_count);

if(server.get_severity_count(UVM_ERROR) == 0 &&
   server.get_severity_count(UVM_FATAL) == 0) begin
    $display("FINAL PASS");
   end
   else
   $display("FINAL FAIL");

endfunction

virtual task run_sequence();
seq =  fifo_smoke_sequence::type_id::create("seq");
endtask

virtual function void check_traffic();
rejected_write_count = write_request_count - expected_write;
rejected_read_count = read_request_count - expected_read;

if(env.sco.write_count !== expected_write) begin
    `uvm_error("test check fatal","write_count !== expected_write");
end
if(env.sco.read_count !== expected_read) begin
    `uvm_error("test check fatal","read_count !== expected_read");
end
if(env.sco.write_request_count !== write_request_count) begin
    `uvm_error("test check fatal","write_request_count");
end
if(env.sco.read_request_count !== read_request_count) begin
    `uvm_error("test check fatal","read_request_count");
end
if(env.sco.rejected_write_count !== rejected_write_count) begin
    `uvm_error("test check fatal","rejected_write_count");
end
if(env.sco.rejected_read_count !== rejected_read_count) begin
    `uvm_error("test check fatal","rejected_read_count");
end
if(env.sco.both_empty_count !== both_empty_count) begin
    `uvm_error("test check fatal","both_empty_count");
end
if(env.sco.both_middle_count !== both_middle_count) begin
    `uvm_error("test check fatal","both_middle_count");
end
if(env.sco.both_full_count !== both_full_count) begin
    `uvm_error("test check fatal","both_full_count");
end
endfunction

endclass
