class ReferenceModel#(parameter DATA_WIDTH = 8,parameter DEPTH=16);

Transaction #(DATA_WIDTH,DEPTH)tr;
logic [DATA_WIDTH-1:0]fifo[$];
logic [DATA_WIDTH-1:0] last_rd_data;
bit can_read;
bit can_write;


function Transaction #(DATA_WIDTH,DEPTH) expected(
              input logic rst_n,
              input logic wr_en,
              input logic rd_en,
              input logic [DATA_WIDTH-1:0]wr_data
              );
tr=new();
tr.rst_n=rst_n;
tr.wr_en=wr_en;
tr.rd_en=rd_en;
tr.wr_data=wr_data;
tr.rd_valid=0;
can_read  = (fifo.size() > 0);
can_write = (fifo.size() < DEPTH);

if(!rst_n) begin
fifo.delete();
tr.rd_data = last_rd_data;
end
else  begin 
if(rd_en&&can_read) begin
tr.rd_data=fifo.pop_front(); 
last_rd_data=tr.rd_data;
tr.rd_valid=1; 
end else tr.rd_data=last_rd_data;           
if(wr_en&&can_write) begin
fifo.push_back(wr_data);
end
end

tr.full=(fifo.size()==DEPTH);
tr.empty=(fifo.size()==0);
tr.count=fifo.size();

return tr;

endfunction

endclass