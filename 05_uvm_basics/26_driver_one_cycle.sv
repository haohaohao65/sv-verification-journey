`timescale 1ns/1ns
// 练习 26：让 enable 保持一个时钟周期，再恢复为 0。
// 本题只填写 run_phase 中的两个 TODO；上一题写对的等待与赋值已保留。
import uvm_pkg::*;
`include "uvm_macros.svh"

interface demo_if;
    logic clk; // clock 的缩写，时钟信号。
    logic enable;
endinterface

// item 保存本次请求的数据；enable 表示希望接口信号取什么值。
class enable_item extends uvm_sequence_item;
    `uvm_object_utils(enable_item)
    bit enable;

    function new(string name = "enable_item");
        super.new(name);
    endfunction
endclass

class enable_sequencer extends uvm_sequencer #(enable_item);
    `uvm_component_utils(enable_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class enable_sequence extends uvm_sequence #(enable_item);
    `uvm_object_utils(enable_sequence)

    function new(string name = "enable_sequence");
        super.new(name);
    endfunction

    virtual task body();
        enable_item req_h;
        req_h = enable_item::type_id::create("req");
        start_item(req_h);
        req_h.enable = 1;
        $display("sequence: request enable=%0d", req_h.enable);
        finish_item(req_h);
        $display("sequence: completed at %0d ns", $time);
    endtask
endclass

class enable_driver extends uvm_driver #(enable_item);
    `uvm_component_utils(enable_driver)
    virtual interface demo_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        bit found;
        super.build_phase(phase);
        found = uvm_config_db #(virtual interface demo_if)::get(this, "", "vif", vif);
        if (!found) begin
            `uvm_fatal("MISSING_VIF", "Driver could not get the interface reference")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        enable_item req_h;
        forever begin
            seq_item_port.get_next_item(req_h);

            $display("driver: got request at %0d ns", $time);
            // 在第一个下降沿开始本次操作，沿用上一题的代码。
            @(negedge vif.clk);
            vif.enable = req_h.enable;
            
            $display("driver: wrote enable=%0d at %0d ns", vif.enable, $time);
            if (vif.enable != req_h.enable) begin
                `uvm_error("ENABLE_CHECK", "Interface signal does not match the request")
            end
            // 本例时钟首次下降沿发生在 10 ns。
            if ($time != 10) begin
                `uvm_error("CLOCK_CHECK", "Expected the write at the first falling edge, 10 ns")
            end
            // TODO 1：等待 vif.clk 的下一个下降沿，使 enable 保持一个完整周期。
            @(negedge vif.clk)
            // TODO 2：通过 vif，把接口中的 enable 信号恢复为 0。
            vif.enable = 0;
            
            $display("driver: cleared enable=%0d at %0d ns", vif.enable, $time);
            if (vif.enable != 0) begin
                `uvm_error("CLEAR_CHECK", "Expected enable to be cleared")
            end
            if ($time != 20) begin
                `uvm_error("HOLD_CHECK", "Expected the operation to end at 20 ns")
            end
            // 本例约定：信号恢复为 0 后，才通知这条请求处理完成。
            seq_item_port.item_done();
        end
    endtask
endclass

class driver_one_cycle_test extends uvm_test;
    `uvm_component_utils(driver_one_cycle_test)
    enable_driver drv_h;
    enable_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = enable_driver::type_id::create("drv", this);
        sqr_h = enable_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        enable_sequence seq_h;
        phase.raise_objection(this);
        seq_h = enable_sequence::type_id::create("seq");
        seq_h.start(sqr_h);
        phase.drop_objection(this);
    endtask
endclass

module tb_driver_one_cycle;
    demo_if bus_if();

    // 时钟从 0 开始，每隔 5 ns 翻转一次。~ 表示按位取反。
    // 5 ns 上升、10 ns 下降、15 ns 上升……
    always #5ns bus_if.clk = ~bus_if.clk;

    // 只读取信号：观察两个下降沿之间的上升沿上，enable 是否仍为 1。
    always @(posedge bus_if.clk) begin
        $display("observer: enable=%0d at %0d ns", bus_if.enable, $time);
    end

    initial begin
        bus_if.clk = 0;
        bus_if.enable = 0;
        $display("module: before enable=%0d", bus_if.enable);
        uvm_config_db #(virtual interface demo_if)::set(null, "uvm_test_top.drv", "vif", bus_if);
        run_test("driver_one_cycle_test");
    end
endmodule
