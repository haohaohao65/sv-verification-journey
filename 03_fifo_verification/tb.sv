
module tb;

    parameter DATA_WIDTH=8;
    parameter DEPTH=16;

    logic clk;
    initial clk=0;
    always #5ns clk=~clk;

    fifo_if #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) f_if(clk);    //把参数传给fifo_if,不过这个项目fifo_if里已经有默认值，这个就会覆盖

    fifo#(.DATA_WIDTH(DATA_WIDTH),
          .DEPTH(DEPTH)
          ) 
    dut(
        .f_if(f_if)
    );

Environment #(DATA_WIDTH,DEPTH) env;

initial begin
    env=new(f_if);

    f_if.rst_n   = 0;
    f_if.wr_en   = 0;
    f_if.rd_en   = 0;
    f_if.wr_data = '0;

    env.run();

    $display("total:%0d", env.sco.total);
$display("pass:%0d",  env.sco.pass);
$display("error:%0d", env.sco.error);

$display("Functional coverage = %0.2f%%",
         env.cov.cg.get_coverage());

$display("rst_n coverage = %0.2f%%",
         env.cov.cg.cp_a.get_coverage());

$display("wr_en coverage = %0.2f%%",
         env.cov.cg.cp_b.get_coverage());

$display("rd_en coverage = %0.2f%%",
         env.cov.cg.cp_c.get_coverage());

$display("full coverage = %0.2f%%",
         env.cov.cg.cp_e.get_coverage());

$display("empty coverage = %0.2f%%",
         env.cov.cg.cp_f.get_coverage());
$display("count coverage = %0.2f%%", 
         env.cov.cg.cp_g.get_coverage());
$display("wr_data coverage = %0.2f%%", 
         env.cov.cg.cp_d.get_coverage());

$finish;


end
    

endmodule