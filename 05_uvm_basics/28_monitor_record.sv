`timescale 1ns/1ns
// 练习 28：Monitor 将接口上的采样值保存成一个独立的数据对象。
// 只填写 Monitor 中的两个 TODO：创建记录对象，再保存接口采样值。
import uvm_pkg::*;
`include "uvm_macros.svh"

interface demo_if;
    logic clk; // clock 的缩写，时钟信号。
    logic enable;
endinterface

// 同一种数据类型可用于请求和观察记录，但两者是分别创建的对象。
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
            // 等待下一个下降沿，沿用你上一题写好的代码。
            @(negedge vif.clk)
            // 恢复接口信号，沿用你上一题写好的代码。
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

// Monitor = 监视器；只观察接口，不接收 Sequence 请求，也不修改接口信号。
class enable_monitor extends uvm_monitor;
    `uvm_component_utils(enable_monitor)
    virtual interface demo_if vif;
    int observed_count;
    enable_item observed_h; // 保存最近一次观察记录的对象句柄。

    function new(string name, uvm_component parent);
        super.new(name, parent);
        observed_count = 0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        bit found;
        super.build_phase(phase);
        found = uvm_config_db #(virtual interface demo_if)::get(this, "", "vif", vif);
        if (!found) begin
            `uvm_fatal("MISSING_VIF", "Monitor could not get the interface reference")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if (vif.enable == 1) begin
                // TODO 1：用 enable_item::type_id::create 创建新的记录对象。
                // 对象名字填 "observed"，只传名字；把返回句柄保存到 observed_h。
                observed_h = enable_item::type_id::create("observed");

                // TODO 2：将接口信号 vif.enable 的当前值，保存到记录的 enable 字段。
                // 左边是对象字段，右边是接口信号；不要修改接口信号。
                observed_h.enable = vif.enable;
                
                observed_count = observed_count + 1;
                $display("monitor: recorded enable=%0d at %0d ns", observed_h.enable, $time);
            end
        end
    endtask
endclass

class monitor_record_test extends uvm_test;
    `uvm_component_utils(monitor_record_test)
    enable_driver drv_h;
    enable_monitor mon_h;
    enable_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = enable_driver::type_id::create("drv", this);
        mon_h = enable_monitor::type_id::create("mon", this);
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
        $display("test: monitor observed_count=%0d", mon_h.observed_count);
        if (mon_h.observed_count != 1) begin
            `uvm_error("MONITOR_CHECK", "Expected exactly one observed operation")
        end
        else begin
            // Driver 已在 20 ns 恢复接口信号；观察记录仍保存 15 ns 的采样值。
            $display("test: saved observation enable=%0d at %0d ns", mon_h.observed_h.enable, $time);
        end
        phase.drop_objection(this);
    endtask
endclass

module tb_monitor_record;
    demo_if bus_if();

    // 时钟从 0 开始，每隔 5 ns 翻转一次。~ 表示按位取反。
    // 5 ns 上升、10 ns 下降、15 ns 上升……
    always #5ns bus_if.clk = ~bus_if.clk;

    // 上一题模块中的观察流程，已搬到上面的 enable_monitor 类中。

    initial begin
        bus_if.clk = 0;
        bus_if.enable = 0;
        $display("module: before enable=%0d", bus_if.enable);
        uvm_config_db #(virtual interface demo_if)::set(null, "uvm_test_top.drv", "vif", bus_if);
        uvm_config_db #(virtual interface demo_if)::set(null, "uvm_test_top.mon", "vif", bus_if);
        run_test("monitor_record_test");
    end
endmodule
