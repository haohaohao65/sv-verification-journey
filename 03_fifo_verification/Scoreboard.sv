class Scoreboard#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
Transaction #(DATA_WIDTH,DEPTH)expected;

mailbox mb_sco;
ReferenceModel #(DATA_WIDTH,DEPTH) ref_model;
int total=0;
int pass=0;
int error=0;

function new(mailbox mb_sco);
this.mb_sco=mb_sco;
ref_model=new();
endfunction

bit match;

task run();

repeat(1000) begin
mb_sco.get(tr);

expected=ref_model.expected(tr.rst_n,tr.wr_en,tr.rd_en,tr.wr_data);

tr.display("Actual ");          // 打印实际收到的
expected.display("Expected");   // 打印预期的

match=(tr.full===expected.full)&&(tr.empty===expected.empty)&&(tr.count==expected.count);

if(expected.rd_valid)
match&=(tr.rd_data===expected.rd_data);

if(match) begin
$display("pass");
pass=pass+1;
end
else begin
$display("error");
error=error+1;
end

total=total+1;

end

endtask

endclass