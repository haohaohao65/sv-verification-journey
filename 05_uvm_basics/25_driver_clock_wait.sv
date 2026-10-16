`timescale 1ns/1ns
// 练习 25：Driver 收到请求后，等待时钟下降沿，再写接口信号。
// 本题只填写 run_phase 中的一行 TODO；其余内容用来承接前面的练习。
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
            // TODO：等待 vif.clk 的下一个下降沿，然后再执行下面的赋值。
            // 使用 @(边沿类型 信号表达式); 这条等待语句。
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
            seq_item_port.item_done();
        end
    endtask
endclass

class driver_clock_test extends uvm_test;
    `uvm_component_utils(driver_clock_test)
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

module tb_driver_clock_wait;
    demo_if bus_if();

    // 时钟从 0 开始，每隔 5 ns 翻转一次。~ 表示按位取反。
    // 5 ns 上升、10 ns 下降、15 ns 上升……
    always #5ns bus_if.clk = ~bus_if.clk;

    initial begin
        bus_if.clk = 0;
        bus_if.enable = 0;
        $display("module: before enable=%0d", bus_if.enable);
        uvm_config_db #(virtual interface demo_if)::set(null, "uvm_test_top.drv", "vif", bus_if);
        run_test("driver_clock_test");
    end
endmodule
