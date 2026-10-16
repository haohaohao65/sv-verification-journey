`timescale 1ns / 1ps

import uvm_pkg::*;
import fifo_tb_pkg::*;

module tb_top#(parameter Depth=8,parameter Width=16);

logic clk;
initial clk=0;
always #5ns clk=~clk;

fifo_if #(
    .Depth(Depth),
    .Width(Width)
) vif(
    .clk(clk)
    );

sync_fifo #(
    .Depth(Depth),
    .Width(Width)
) dut(
    .clk(vif.clk),
    .reset(vif.reset),
    .w_enb(vif.w_enb),
    .r_enb(vif.r_enb),
    .din(vif.din),
    .dout(vif.dout),
    .empty(vif.empty),
    .full(vif.full)
);


initial begin
    vif.reset=1;
    vif.w_enb=0;
    vif.r_enb=0;
    vif.din=0;
    @(posedge clk);
    @(posedge clk);

    @(negedge clk);
    vif.reset=0;
    @(posedge clk);
    @(posedge clk);

end

initial begin
    string test_name;

    if(!$value$plusargs("TESTNAME=%s",test_name)) begin  //尝试读取命令行参数
        test_name = "fifo_test";
    end

    uvm_config_db#(virtual fifo_if #(.Depth(Depth), .Width(Width)))::set(null,"uvm_test_top","vif",vif);
    $timeformat(-9, 0, " ns", 0);
    uvm_top.set_timeout(5us, 0);

    run_test(test_name);

end

endmodule
