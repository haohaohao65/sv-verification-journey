module tb;

logic clk;
initial clk=0;
always #5ns clk=~clk;

handshake_if h_if(clk);

handshake_dut dut(.h_if(h_if));
sva_checker ch(.h_if(h_if));

task drive(input logic a,input logic b,input logic[7:0] c);
#1ns;
h_if.rst_n=a;
h_if.valid=b;
h_if.data=c;
endtask

initial begin
   // reset
    drive(0, 0, 8'h00);

    // 正常握手
    @(posedge clk);
    drive(1, 1, 8'hAA);

    @(posedge clk);
    drive(1, 1, 8'hAA);

    // ready=0期间，故意让valid变0
    @(posedge clk);
    drive(1, 0, 8'hAA);

    // 等ready恢复
    @(posedge clk);
    drive(1, 0, 8'hAA);

    // 再次握手
    @(posedge clk);
    drive(1, 1, 8'hAA);

    @(posedge clk);
    drive(1, 1, 8'hAA);

    // ready=0期间，故意修改data
    @(posedge clk);
    drive(1, 1, 8'hA0);

    #10ns;
    $finish;
end

endmodule