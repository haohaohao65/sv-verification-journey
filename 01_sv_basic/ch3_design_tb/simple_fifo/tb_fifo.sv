module tb_fifo;

logic clk;

initial clk=0;
always #5ns clk=~clk;

logic rst_n;

logic wr_en;
logic [7:0]wr_data;

logic rd_en;
logic [7:0]rd_data;

logic full;
logic empty;

simple_fifo d1(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);

task drive(input logic a,input logic b,input logic c,input logic [7:0]d);
rst_n=a;
wr_en=b;
rd_en=c;
wr_data=d;
endtask

task checker();
$display("full=%0d",full);
$display("empty=%0d",empty);
endtask

task test(input logic a,input logic b,input logic c,input logic [7:0]d);
drive(a,b,c,d);
checker();
endtask

task rd();
if(rd_en)
$display("rd_data=%0d",rd_data);
endtask

initial begin
    test(0,0,0,8'h0);
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,1,0,8'hAA);
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,1,0,8'hBB);
    @(posedge clk);
    rd();

    #1ps;
    test(1,1,0,8'hCC);
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,1,0,8'hDD);
    @(posedge clk);
    #1ps;
    rd();


    #1ps;
    test(1,0,1,8'h0);   
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,0,1,8'h0);
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,0,1,8'h0);
    @(posedge clk);
    #1ps;
    rd();

    #1ps;
    test(1,0,1,8'h0);
    @(posedge clk);
    #1ps;
    rd();


    $finish

end


endmodule