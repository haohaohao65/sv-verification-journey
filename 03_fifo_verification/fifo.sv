module fifo#(parameter DATA_WIDTH=8,parameter DEPTH=16)(fifo_if.dut_if f_if);
logic [DATA_WIDTH-1:0]data [0:DEPTH-1];
logic [$clog2(DEPTH)-1:0] wr_ptr;
logic [$clog2(DEPTH)-1:0] rd_ptr;

assign f_if.full=(f_if.count==DEPTH);
assign f_if.empty=(f_if.count==0);

logic do_write;
logic do_read;

assign do_write=(!f_if.full&&f_if.wr_en);
assign do_read=(!f_if.empty&&f_if.rd_en);

always_ff @(posedge f_if.clk)
if(!f_if.rst_n) begin
f_if.count<=0;
wr_ptr<=0;
rd_ptr<=0;
end
else begin if(do_write) begin
data[wr_ptr]<=f_if.wr_data; 
if(wr_ptr==DEPTH-1)
wr_ptr<=0;
else
wr_ptr<=wr_ptr+1;
end
if(do_read) begin 
f_if.rd_data<=data[rd_ptr];
if(rd_ptr==DEPTH-1)
rd_ptr<=0;
else
rd_ptr<=rd_ptr+1;
end
if(do_write&&!do_read)
f_if.count<=f_if.count+1;
else if(!do_write&&do_read)
f_if.count<=f_if.count-1;

end

endmodule